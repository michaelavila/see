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
        project = get_project(plugin_config['project'])
        stories_being_worked_on(project, lines)
        next_story_to_be_worked_on(project, lines)
        lines
      end

      def get_project(project)
        PivotalTracker::Client.token = access_token('PIVOTAL_TRACKER_ACCESS_TOKEN')
        project = PivotalTracker::Project.find(project)
      end

      def stories_being_worked_on(project, lines)
        stories = project.stories.all.select do |story|
          story.current_state != 'unscheduled'
        end.map do |story|
          owner = "[#{story.owned_by}]".cyan
          time = "- #{story.created_at.strftime("%b %e,%l:%M %p")}".black
          id = "#{story.id}".light_yellow
          "    - #{story.name} #{owner} #{id} #{time}"
        end

        if stories.length > 0
          lines << "  Stories being worked on:".light_blue
          lines << stories
        else
          lines << "  No stories being worked on".yellow
        end
      end

      def next_story_to_be_worked_on(project, lines)
        next_unowned_story = project.stories.all.select do |story|
          story.current_state == 'unscheduled'
        end.first

        if next_unowned_story
          lines << "  Next story that can be worked on:".light_blue
          time = "- #{next_unowned_story.created_at.strftime("%b %e,%l:%M %p")}".black
          id = "#{next_unowned_story.id}".light_yellow
          name = next_unowned_story.name
          lines << "    - #{id} #{name} #{time}"
        else
          lines << "  No stories ready to work on".yellow
        end
      end
    end
  end
end
