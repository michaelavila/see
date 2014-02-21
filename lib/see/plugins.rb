module See
  module Plugins
    require 'colorize'

    def self.plugins
      See::Plugins.constants.map do |const|
        See::Plugins.const_get(const).new
      end
    end

    def self.run_plugin(name, config)
      lines = []
      plugins = See::Plugins.plugins.select do |plugin|
        plugin.config_name == name
      end.each do |plugin|
        lines << "\n"
        lines << plugin.display_name.light_magenta
        lines.concat(plugin.run(config, config[plugin.config_name]))
      end
      
      if plugins.empty?
        lines << "\nNo plugin found with the name \"#{name}\"".light_red
      end
      lines
    end
  end
end
