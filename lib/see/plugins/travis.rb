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
        info = []
        repository = plugin_config["repository"]
        builds = Travis::Repository.find(repository).recent_builds[0..4].map do |build|
          time = ( build.finished_at ? "- #{build.finished_at.strftime("%b %e,%l:%M %p")}" : "- running" ).black
          if build.pending?
            state = build.state.capitalize.cyan
          else
            state = build.unsuccessful? ? build.state.capitalize.red : build.state.capitalize.green
          end
          name = "[#{build.commit.author_name}]".cyan
          "    - #{state} #{build.commit.short_sha.light_yellow} #{("#"+build.number).light_green} #{build.commit.subject} #{name} #{time}"
        end

        if builds.count > 0
          info << "  Latest Builds:".light_blue
          info.concat(builds)
        else
          info << "No available build status".yellow
        end
        info
      end
    end
  end
end
