require 'travis'

module See
  module Plugins
    class TravisCI
      def display_name
        'Travis CI'
      end

      def config_name
        'travis'
      end

      def run(config, plugin_config)
        lines = []
        builds = recent_builds(plugin_config['repository'])
        if builds.count == 0
          return ["No available build status".yellow]
        end

        lines << "  Latest Builds:".light_blue
        lines << builds.map do |build|
          state = colorize_state(build)
          commit_id = build.commit.short_sha.light_yellow
          build_number = ("#"+build.number).light_green
          author = "[#{build.commit.author_name}]".cyan
          fmt = "%b %e,%l:%M %p"
          time = (build.finished_at ? "- #{build.finished_at.strftime(fmt)}" : "- running").black

          "    - #{state} #{commit_id} #{build_number} #{build.commit.subject} #{author} #{time}"
        end
      end

      def recent_builds(repository)
        Travis::Repository.find(repository).recent_builds[0..4]
      end

      def colorize_state(build)
        if build.successful?
          state_color = :green
        elsif build.unsuccessful?
          state_color = :red
        else
          state_color = :cyan
        end
        state = build.state.capitalize.send(state_color)
      end
    end
  end
end
