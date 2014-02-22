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

        begin
          builds = recent_builds(plugin_config['account'], plugin_config['repository'], lines)
        rescue => error
          return lines
        end

        if builds.count == 0
          return ["No available build status".yellow]
        end

        lines << "  Latest Builds:".light_blue
        lines << builds.map do |build|
          turn_build_into_line(build)
        end
      end

      def turn_build_into_line(build)
          time = "- #{Date.parse(build['committer_date']).strftime("%b %e,%l:%M %p")}".black if build['committer_date'] 
          was_bad = build['status'].match(/failed|not_run/)
          status = build['status'].capitalize.send(was_bad ? :red : :green)
          name = "[#{build['committer_name']}]".cyan ||= ''
          commit_id = build["vcs_revision"][0..8].light_yellow
          build_number = ("#"+build['build_num'].to_s).light_green

          "    - #{status} #{commit_id} #{build_number} #{build['subject']} #{name} #{time}"
      end

      def recent_builds(account, repository, lines)
        token = access_token('CIRCLE_CI_ACCESS_TOKEN')
        CircleCi.configure do |cfg|
          cfg.token = token
        end

        response = CircleCi::Project.recent_builds(account, repository)
        if response.errors.length > 0
          lines << "  Errors encountered:".red
          response.errors.each do |error|
            lines << "    - " + "Error #{error.code}:".red + " #{JSON.parse(error.message)['message'].strip}"
            raise
          end
        end

        response.body[0..4]
      end
    end
  end
end
