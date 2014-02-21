require 'json'
require 'circleci'

module See
  module Plugins
    class Circle
      def display_name
        'CircleCi'
      end

      def config_name
        'circle'
      end

      def run(config, plugin_config)
        info = []
        token = ENV['CIRCLE_CI_ACCESS_TOKEN']
        unless token
          info << "  You must set CIRCLE_CI_ACCESS_TOKEN env variable".red
          return info
        end

        CircleCi.configure do |cfg|
          cfg.token = token
        end

        response = CircleCi::Project.recent_builds(plugin_config['account'], plugin_config['repository'])
        if response.errors.length > 0
          info << "Circle CI - " + "Errors encountered:".red
          response.errors.each do |error|
            info << "  - " + "Error #{error.code}:".red + " #{JSON.parse(error.message)['message'].strip}"
          end
          return info
        end

        info << "  Latest Builds:".light_blue
        response.body[0..4].each do |thing|
          if thing['committer_date']
            time = "- #{Date.parse(thing['committer_date']).strftime("%b %e,%l:%M %p")}".black
          end
          if thing['status'].match(/failed|not_run/)
            status = thing['status'].red
          else
            status = thing['status'].green
          end
          if thing['committer_name']
            name = "[#{thing['committer_name']}]".cyan
          else
            name = ""
          end
          info << "    - #{status.capitalize} #{thing["vcs_revision"][0..8].light_yellow} #{("#"+thing['build_num'].to_s).light_green} #{thing['subject']} #{name} #{time}"
        end
        info
      end
    end
  end
end
