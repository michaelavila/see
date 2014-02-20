module See
  module Plugins
    require 'colorize'
    require 'circleci'

    def self.run_plugin(name, config)
      plugins = See::Plugins.constants.map do |const|
        plugin = See::Plugins.const_get(const).new
      end.select do |plugin|
        plugin.config_name == name
      end
      
      info = []
      plugins.each do |plugin|
        info.concat(plugin.run(config))
      end
      
      if plugins.empty?
        info << "No plugin found with the name \"#{name}\"".light_red
      end
      info
    end
  end
end
