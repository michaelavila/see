require 'octokit'

module See
  module Plugins
    class GitHub < Plugin
      def display_name
        'GitHub'
      end

      def config_name
        'github'
      end

      def run(config, plugin_config)
        lines = []
        github_name = "#{plugin_config['account']}/#{plugin_config['repository']}"
        client = get_client(github_name)
        show_collection('Pull Requests', client.pull_requests(github_name), lines)
        show_collection('Issues', client.issues(github_name), lines)
        lines
      end

      def get_client(github_name)
        token = access_token('GITHUB_ACCESS_TOKEN')
        return Octokit::Client.new(:access_token => token)
      end

      def show_collection(name, collection, lines)
        if collection.count == 0
          return ["  No open #{name.downcase}".yellow]
        end

        lines << "  Open #{name.downcase}:".light_blue
        lines << collection.map do |github_object|
          username = "[#{github_object.user.login}]".cyan
          time = "- #{github_object.updated_at.strftime("%b %e,%l:%M %p")}".black
          "    - #{github_object.title} #{username} #{time}"
        end
      end
    end
  end
end
