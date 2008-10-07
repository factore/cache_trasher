# CacheTrasher
module ActionController::Caching::Pages
  module ClassMethods
  
    def trash_cache(path)
      return unless perform_caching
      
      # check if the action or controller has been saved as a cached file
      # as opposed to just a directory.
      paths = [path.chomp('/')]
      paths << "#{paths[0]}#{page_cache_extension}" if File.exist?("#{page_cache_directory}/#{paths[0]}#{page_cache_extension}")

      paths.each do |p|
        p = page_cache_directory + p
        unless [p, p.chomp, p.chomp('/'), p.chomp('/*')].include? Rails.public_path 
          benchmark "Removing cache file or directory: #{p}" do
            FileUtils.rm_r(p)
          end
        else
          # drop a long message into the log if they try to delete RAILS_ROOT/public
          File.open("#{RAILS_ROOT}/vendor/plugins/cache_trasher/warning.txt", 'r') { |f| logger.info f.read }
        end
      end
    end
    
  end
  
  def trash_cache(options = "")
    return unless perform_caching
    
    path = case options
    when Hash
      url_for(options.merge(:only_path => true, :skip_relative_url_root => true))
    when String
      options
    end
    
    self.class.trash_cache(path)
  end
end