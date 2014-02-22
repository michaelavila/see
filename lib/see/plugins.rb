require 'colorize'

module See
  module Plugins
    def self.run_plugin(name, config)
      plugins = See::Plugins.constants.select do |const|
        const != :Plugin
      end.map do |const|
        See::Plugins.const_get(const).new
      end.select do |plugin|
        plugin.config_name == name
      end

      lines = []
      if plugins.empty?
        lines << "\nNo plugin found with the name \"#{name}\"".light_red
      else
        plugins.each do |plugin|
          lines << "\n"
          lines << plugin.display_name.light_magenta
          begin
            lines_from_plugin = plugin.run(config, config[plugin.config_name])
          rescue => error
            lines_from_plugin = ["  #{error.message}".red]
          end
          lines.concat(lines_from_plugin)
        end
      end
      lines
    end

    class Plugin
      def access_token(name)
        token = ENV[name]
        unless token
          raise "  You must set #{name} env variable"
        end
        token
      end
    end
  end
end

require_relative 'plugins/github'
require_relative 'plugins/pivotal'
require_relative 'plugins/travis'
require_relative 'plugins/circle'
