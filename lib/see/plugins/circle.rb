
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
        info << "\nCircleCI - " + "Latest Builds:".light_blue
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
          info << "  - #{status.capitalize} #{thing["vcs_revision"][0..8].light_yellow} #{("#"+thing['build_num'].to_s).light_green} #{thing['subject']} #{name} #{time}"
        end
      end
    end
  end
end
