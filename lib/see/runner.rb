module See
  module Runner
    def self.run
      #
      # Whole thing happens in two major steps:
      #   1. load ./see.yml
      #     (fail if it doesn't exist)
      #
      #   2. provide information from each configured plugin
      #     (provide content at the top and no content at the bottom)
      #
      config = See::Config.load
      progress = ProgressIndicator.start(config.length)
      threads = config.map do |cfg|
        Thread.new do
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
      lines.each { |t| puts t }
      puts
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
end
