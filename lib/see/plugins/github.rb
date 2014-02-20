require 'octokit'

module See
  module Plugins
    class GitHub
      def config_name
        'github'
      end

      def run(config)
        info = []
        token = ENV['GITHUB_ACCESS_TOKEN']
        unless token
          info << "\nGitHub".light_red
          info << "  You must set GITHUB_ACCESS_TOKEN env variable".red
          return info
        end

        client = Octokit::Client.new :access_token => token
        account = config['github']['account']
        repository = config['github']['repository']
        github_name = [account, repository].join '/'

        pull_requests = client.pull_requests(github_name)
        info << "\nGitHub".light_magenta
        if pull_requests.count > 0
          info << "  Open pull requests:".light_blue
          pull_requests.each do |pull_request|
            username = "[#{pull_request.user.login}]".cyan
            time = "- #{pull_request.updated_at.strftime("%b %e,%l:%M %p")}".black
            info << "    - #{pull_request.title} #{username} #{time}"
          end
        else
          info << "  No open pull requests".yellow
        end

        issues = client.issues(github_name)
        if issues.count > 0
          info << "  Open issues:".light_blue
          issues.each do |issue|
            username = "[#{issue.user.login}]".cyan
            time = "- #{issue.updated_at.strftime("%b %e,%l:%M %p")}".black
            info << "    - #{issue.title} #{username} #{time}"
          end
        else
          info << "No open issues".yellow
        end
        info
      end
    end
  end
end
