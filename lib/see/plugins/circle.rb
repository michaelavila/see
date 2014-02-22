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

      def latest_builds(account, repository, lines)
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

      def run(config, plugin_config)
        lines = []

        begin
          builds = latest_builds(plugin_config['account'], plugin_config['repository'], lines)
        rescue => error
          return lines
        end

        lines << "  Latest Builds:".light_blue
        lines << builds.map do |build|
          time = "- #{Date.parse(build['committer_date']).strftime("%b %e,%l:%M %p")}".black if build['committer_date'] 
          was_bad = build['status'].match(/failed|not_run/)
          status = build['status'].capitalize.send(was_bad ? :red : :green)
          name = "[#{build['committer_name']}]".cyan ||= ''
          commit_id = build["vcs_revision"][0..8].light_yellow
          build_number = ("#"+build['build_num'].to_s).light_green

          "    - #{status} #{commit_id} #{build_number} #{build['subject']} #{name} #{time}"
        end
        lines
      end
    end
  end
end
