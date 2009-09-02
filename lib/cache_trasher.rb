# CacheTrasher
module ActionController::Caching::Pages
  module ClassMethods
  
    def trash_cache(path, options)
      return unless perform_caching
      
      # check if the action or controller has been saved as a cached file
      # as opposed to just a directory.
      paths = [path.chomp('/')]
      # if options includes format(s), then use those, otherwise use the standard page_cache_extension to pick stuff up
      if options[:format]
        options[:format].to_a.each do |format|
          paths << "#{paths[0]}.#{format}" if File.exist?("#{page_cache_directory}/#{paths[0]}.#{format}")
        end
      else
        paths << "#{paths[0]}#{page_cache_extension}" if File.exist?("#{page_cache_directory}/#{paths[0]}#{page_cache_extension}")
      end
      paths.each do |p|
        p = File.join(page_cache_directory, p)
        unless [p, p.chomp, p.chomp('/'), p.chomp('/*')].include? Rails.public_path 
          benchmark "Removing cache file or directory: #{p}" do
            FileUtils.rm_r(p) rescue Errno::ENOENT
          end
        else
          # drop a long message into the log if they try to delete RAILS_ROOT/public
          File.open("#{RAILS_ROOT}/vendor/plugins/cache_trasher/warning.txt", 'r') { |f| logger.info f.read }
        end
      end
    end
    
  end
  
  def trash_cache(supplied_path = "", options = {})
    return unless perform_caching
    
    path = case supplied_path
    when Hash
      url_for(options.merge(:only_path => true, :skip_relative_url_root => true))
    when String
      supplied_path
    end
    
    self.class.trash_cache(path, options)
  end
end