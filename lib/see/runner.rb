require 'yaml'

module See
  class Runner
    def self.run
      Runner.new.run
    end

    def run
      #
      # Whole thing happens in two major steps:
      #   1. load ./see.yml
      #     (fail if it doesn't exist)
      #
      #   2. provide information from each configured plugin
      #     (provide content at the top and no content at the bottom)
      #
      config = load_config

      progress = ProgressIndicator.start(config.length)
      threads = []
      config.each do |cfg|
        threads << Thread.new do
          begin
            Thread.current[:lines] = See::Plugins.run_plugin(cfg[0], config)
          rescue => error
            Thread.current[:lines] = "\nError running plugin: #{cfg[0]}".red
            Thread.current[:lines] << "\n  #{error}".light_red
          end
        end
      end
      lines = threads.map { |t| t.join[:lines] }.sort_by { |l| l[0] }
      progress.stop

      puts
      puts lines.join "\n"
      puts
    end

    def load_config
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

  class ProgressIndicator
    def self.start(things_todo_count)
      progress = ProgressIndicator.new
      progress.start(things_todo_count)
      progress
    end

    def start(things_todo_count)
      @progress = Thread.new do
        print "Pulling data from #{things_todo_count} source#{things_todo_count == 1 ? '' : 's'}"
        loop do
          sleep 0.25
          print '.'
        end
      end
    end

    def stop
      @progress.kill
    end
  end
end
