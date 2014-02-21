module See
  module Plugins
    require 'colorize'

    def self.run_plugin(name, config)
      plugins = See::Plugins.constants.map do |const|
        plugin = See::Plugins.const_get(const).new
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
          lines.concat(plugin.run(config))
        end
      end
      lines
    end
  end
end
