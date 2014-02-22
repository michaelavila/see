require 'colorize'

module See
  module Plugins
    def self.find_plugins(name)
      See::Plugins.constants.select do |const|
        const != :Plugin
      end.map do |const|
        See::Plugins.const_get(const).new
      end.select do |plugin|
        plugin.config_name == name
      end
    end

    def self.run_plugin(name, config)
      plugins = find_plugins(name)
      if plugins.empty?
        return ["\nNo plugin found with the name \"#{name}\"".light_red]
      end

      lines = ["\n"]
      lines << plugins.map do |plugin|
        lines_from_plugin = [plugin.display_name.light_magenta]
        begin
          lines_from_plugin << plugin.run(config, config[plugin.config_name])
        rescue => error
          lines_from_plugin << ["  #{error.message}".red]
        end
      end
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
