require 'pivotal-tracker'

module See
  module Plugins
    class Pivotal < Plugin
      def display_name
        'Pivotal Tracker'
      end

      def config_name
        "pivotal"
      end

      def run(config, plugin_config)
        lines = []
        @token = access_token('PIVOTAL_TRACKER_ACCESS_TOKEN')

        PivotalTracker::Client.token = @token
        project = PivotalTracker::Project.find(plugin_config['project'])

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
            stories << "    - #{story.name} #{owner} #{id} #{time}"
          end
        end

        if stories.length > 0
          lines << "  Stories being worked on:".light_blue
          lines << stories
        else
          lines << "  No stories being worked on".yellow
        end


        if next_unowned_story
          lines << "  Next story that can be worked on:".light_blue
          time = "- #{next_unowned_story.created_at.strftime("%b %e,%l:%M %p")}".black
          id = "#{next_unowned_story.id}".light_yellow
          name = next_unowned_story.name
          lines << "    - #{id} #{name} #{time}"
        else
          lines << "No stories ready to work on".yellow
        end
        lines
      end
    end
  end
end
