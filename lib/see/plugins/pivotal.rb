require 'pivotal-tracker'

module See
  module Plugins
    class Pivotal
      def config_name
        "pivotal"
      end

      def run(config)
        info = []
        token = ENV['PIVOTAL_TRACKER_ACCESS_TOKEN']
        unless token
          info << "\nPivotal Tracker".light_red
          info << "  You must set PIVOTAL_TRACKER_ACCESS_TOKEN env variable".red
          return info
        end

        PivotalTracker::Client.token = token
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
            time = "- #{story.created_at.strftime("%b %e,%l:%M %p")}".black
            id = "#{story.id}".light_yellow
            stories << "  - #{story.name} #{owner} #{id} #{time}"
          end
        end

        info << "\nPivotal Tracker".light_magenta
        if stories.length > 0
          info << "  Stories being worked on:".light_blue
          info << stories
        else
          info << "  No stories being worked on".yellow
        end


        if next_unowned_story
          info << "  Next story that can be worked on:".light_blue
          time = "- #{next_unowned_story.created_at.strftime("%b %e,%l:%M %p")}".black
          id = "#{next_unowned_story.id}".light_yellow
          name = next_unowned_story.name
          info << "    - #{id} #{name} #{time}"
        else
          info << "No stories ready to work on".yellow
        end
        info
      end
    end
  end
end
