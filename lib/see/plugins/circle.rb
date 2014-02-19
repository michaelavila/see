
module See
  module Plugins
    class Circle
      def config_name
        'circle'
      end

      def run(config, info, no_info)
        CircleCi.configure do |config|
            config.token = '6cb3ee6ee8ed3b2399bfae16294ef2291cfde9bb'
        end

        response = CircleCi::Project.recent_builds(config['circle']['account'], config['circle']['repository'])
        info << "Latest Builds:".light_blue
        response.body.each do |thing|
          time = "(#{thing['stop_time']})".blue if thing['stop_time']
          if thing['status'].match(/failed|not_run/)
            status = thing['status'].red
          else
            status = thing['status'].green
          end
          info << "    - #{status} #{thing["vcs_revision"][0..8].light_yellow} #{("#"+thing['build_num'].to_s).black} #{thing['subject']} #{thing['author_name'].cyan} #{time}"
        end
      end

      def xrun(config, info, no_info)
        client = Travis::Client.new

        repository = config["travis"]["repository"]
        builds = client.repo(repository).recent_builds.map do |build|
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
