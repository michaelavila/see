require 'pivotal-tracker'

module See
  module Plugins
    class Pivotal
      def config_name
        "pivotal"
      end

      def run(config, info, no_info)
        PivotalTracker::Client.token = ENV['PIVOTAL_TRACKER_ACCESS_TOKEN']
        project = PivotalTracker::Project.find(config['pivotal']['project'])

        next_unowned_story = nil
        has_current = false
        stories = []
        project.stories.all.each do |story|
          next if story.accepted_at != nil
          if story.owned_by == nil and not next_unowned_story
            next_unowned_story = story
          elsif story.owned_by
            has_current = true
            owner = "[#{story.owned_by}]".cyan
            time = "(#{story.created_at.strftime("%b %e,%l:%M %p")})".blue
            id = "#{story.id}".light_yellow
            stories << "    - #{story.name} #{owner} #{id} #{time}"
          end
        end

        if stories.length > 0
          info << "Tracker - " + "Stories being worked on:".light_blue
          info << stories
        else
          no_info << "Tracker - " + "No stories being worked on".yellow
        end

        if next_unowned_story
          info << "Tracker - " + "Next story that can be worked on:".light_blue
          time = "(#{next_unowned_story.created_at.strftime("%b %e,%l:%M %p")})".blue
          id = "#{next_unowned_story.id}".light_yellow
          name = next_unowned_story.name
          info << "    - #{name} #{id} #{time}"
        else
          no_info << "Tracker - " + "No stories ready to work on".yellow
        end
      end
    end
  end
end
