require 'travis/client'

module See
  module Plugins

    class TravisCI
      def config_name
        'travis'
      end

      def run(config, info, no_info)
        client = Travis::Client.new

        repository = config["travis"]["repository"]
        builds = client.repo(repository).recent_builds[0..4].map do |build|
          time = "(#{build.finished_at.strftime("%b %e,%l:%M %p")})".blue
          state = build.failed? ? build.state.capitalize.red : build.state.capitalize.green
          "    - #{state} #{build.commit.short_sha.light_yellow} #{build.commit.subject} #{build.job_ids.to_s.light_magenta} #{time}"
        end

        if builds.count > 0
          info << "Latest Builds:".light_blue
          info.concat(builds)
        else
          no_info << "No available build status".yellow
        end
      end
    end
  end
end
