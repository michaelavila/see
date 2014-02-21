require 'yaml'

module See
  module Config
    def self.load
      config_path = "#{Dir.pwd}/see.yml"
      begin
        config = YAML.load_file(config_path)
      rescue => error
        puts "No configuration file found (tried #{config_path})".yellow
        puts '  (if the file exists it may be malformed)'
        puts "  #{error}".light_red
        exit 1
      end
      config
    end
  end
end
