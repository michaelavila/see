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
          See::Plugins.run_plugin(cfg[0], config, good=[], bad=[])
          Thread.current[:good] = good
          Thread.current[:bad] = bad
        end
      end

      good = []
      bad = []
      threads.each do |t|
        t.join
        good << t[:good] if t[:good]
        bad << t[:bad] if t[:bad]
      end

      progress.kill
      puts

      good.sort_by {|a| a[0]}.each {|g| puts g}
      puts
      unless bad.empty?
        puts bad.sort
        puts
      end
    end
  end
end
