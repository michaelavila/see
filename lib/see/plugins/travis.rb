require 'travis'

module See
  module Plugins
    class TravisCI
      def config_name
        'travis'
      end

      def run(config, info, no_info)
        repository = config["travis"]["repository"]
        builds = Travis::Repository.find(repository).recent_builds[0..4].map do |build|
          time = "(#{build.finished_at.strftime("%b %e,%l:%M %p")})".blue
          state = build.failed? ? build.state.capitalize.red : build.state.capitalize.green
          "    - #{state} #{build.commit.short_sha.light_yellow} #{("#"+build.number).light_green} #{build.commit.subject} #{time}"
        end

        if builds.count > 0
          info << "Travis - " + "Latest Builds:".light_blue
          info.concat(builds)
        else
          no_info << "Travis - " + "No available build status".yellow
        end
      end
    end
  end
end
