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

      info = []
      no_info = []
      config.each do |configuration|
        info = []
        name = configuration[0]
        See::Plugins.run_plugin(name, config, info, no_info)
        puts info
      end

      puts
      puts no_info.map(&:yellow)
    end
  end
end
