require 'octokit'

module See
  module Plugins
    class GitHub
      def display_name
        'GitHub'
      end

      def config_name
        'github'
      end

      def run(config, plugin_config)
        info = []
        token = ENV['GITHUB_ACCESS_TOKEN']
        unless token
          info << "  You must set GITHUB_ACCESS_TOKEN env variable".red
          return info
        end

        account = plugin_config['account']
        repository = plugin_config['repository']
        github_name = [account, repository].join '/'

        client = Octokit::Client.new :access_token => token
        pull_requests = client.pull_requests(github_name)
        info.concat(show_collection('Pull Requests', pull_requests))

        issues = client.issues(github_name)
        info.concat(show_collection('Issues', issues))
        info
      end

      def show_collection(name, collection)
        info = []
        if collection.count > 0
          info << "  Open #{name.downcase}:".light_blue
          info << collection.map do |github_object|
            username = "[#{github_object.user.login}]".cyan
            time = "- #{github_object.updated_at.strftime("%b %e,%l:%M %p")}".black
            "    - #{github_object.title} #{username} #{time}"
          end
        else
          info << "  No open #{name.downcase}".yellow
        end
        info
      end
    end
  end
end
