module See
  module Plugins
    require 'colorize'
    require 'circleci'

    def self.run_plugin(name, config, info, no_info)
      plugins = See::Plugins.constants.map do |const|
        plugin = See::Plugins.const_get(const).new
      end.select do |plugin|
        plugin.config_name == name
      end
      
      plugins.each do |plugin|
        plugin.run(config, info, no_info)
      end
      
      if plugins.empty?
        puts "No plugin found with the name \"#{name}\"".light_red
      end
    end
  end
end