require 'yaml'

module See
  class Runner
    def self.run
      Runner.new.run
    end

    def run
      #
      # Whole thing happens in two major steps:
      #   1. load ./sights.yml
      #     (fail if it doesn't exist)
      #
      #   2. provide information from each configured plugin
      #     (provide content at the top and no content at the bottom)
      #
      config_path = "#{Dir.pwd}/sights.yml"
      begin
        config = YAML.load_file(config_path)
      rescue
        puts "No configuration file found (tried #{config_path})".yellow
        puts '  (if the file exists it may be malformed)'
        exit 1
      end

      progress = Thread.new do
        print "Pulling data from #{config.length} source#{config.length == 1 ? '' : 's'}"
        while true
          sleep 0.25
          print '.'
        end
      end

      threads = []
      config.each do |cfg|
        threads << Thread.new do
          Thread.current[:lines] = See::Plugins.run_plugin(cfg[0], config)
        end
      end

      lines = threads.map { |t| t.join[:lines] }
      progress.kill

      puts
      lines.sort_by { |l| l[0] }.each { |l| puts l }
      puts
    end
  end
end
