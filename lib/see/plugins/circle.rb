require 'json'
require 'circleci'

module See
  module Plugins
    class Circle < Plugin
      def display_name
        'CircleCi'
      end

      def config_name
        'circle'
      end

      def run(config, plugin_config)
        lines = []

        token = access_token('CIRCLE_CI_ACCESS_TOKEN')
        CircleCi.configure do |cfg|
          cfg.token = token
        end

        response = CircleCi::Project.recent_builds(plugin_config['account'], plugin_config['repository'])
        if response.errors.length > 0
          lines << "  Errors encountered:".red
          response.errors.each do |error|
            lines << "    - " + "Error #{error.code}:".red + " #{JSON.parse(error.message)['message'].strip}"
          end
          return lines
        end

        lines << "  Latest Builds:".light_blue
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
          lines << "    - #{status.capitalize} #{thing["vcs_revision"][0..8].light_yellow} #{("#"+thing['build_num'].to_s).light_green} #{thing['subject']} #{name} #{time}"
        end
        lines
      end
    end
  end
end
