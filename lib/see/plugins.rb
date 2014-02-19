module See
  module Plugins
    require 'colorize'

    def self.run_plugin(name, config, info, no_info)
      plugins = See::Plugins.constants.map do |const|
        plugin = See::Plugins.const_get(const).new
      end.select do |plugin|
        plugin.config_name == name
      end.each do |plugin|
        plugin.run(config, info, no_info)
      end
    end
  end
end
