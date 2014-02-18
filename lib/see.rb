require 'colorize'
require 'travis'
require 'octokit'
require 'pivotal-tracker'
require 'yaml'

def github(config, info, no_info)
  if config.has_key?('github')
    client = Octokit::Client.new :access_token => ENV['GITHUB_ACCESS_TOKEN']
    account = config['github']['account']
    repository = config['github']['repository']
    github_name = [account, repository].join '/'

    pull_requests = client.pull_requests(github_name)
    if pull_requests.count > 0
      info << "Open pull requests:".light_blue
      pull_requests.each do |pull_request|
        username = "[#{pull_request.user.login}]".cyan
        time = "(#{pull_request.updated_at.strftime("%b %e,%l:%M %p")})".blue
        info << "    - #{pull_request.title} #{username} #{time}"
      end
    else
      no_info << "No open pull requests"
    end

    issues = client.issues(github_name)
    if issues.count > 0
      info << "Open issues:".light_blue
      issues.each do |issue|
        username = "[#{issue.user.login}]".cyan
        time = "(#{issue.updated_at.strftime("%b %e,%l:%M %p")})".blue
        info << "    - #{issue.title} #{username} #{time}"
      end
    else
      no_info << "No open issues"
    end
  end
end

def pivotal(config, info, no_info)
  if config.has_key?('pivotal')
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
      info << "Stories being worked on:".light_blue
      info << stories
    else
      no_info << "No stories being worked on"
    end

    if next_unowned_story
      info << "Next story that can be worked on:".light_blue
      time = "(#{next_unowned_story.created_at.strftime("%b %e,%l:%M %p")})".blue
      id = "#{next_unowned_story.id}".light_yellow
      name = next_unowned_story.name
      info << "    - #{name} #{id} #{time}"
    else
      no_info << "No stories ready to work on"
    end
  end
end

def travis(config, info, no_info)
  if config.has_key?('travis')
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

#
# Processing of plugins
#

config_path = "#{Dir.pwd}/sights.yml"
begin
  config = YAML.load_file(config_path)
rescue
  puts "No configuration file found (tried #{config_path})".yellow
  puts '  (if the file exists it may be malformed)'
  exit 1
end

information = []
no_information = []
config.each do |configuration|
  information = []
  service_name = configuration[0]
  self.send(service_name, config, information, no_information)
  puts information
end

puts
puts no_information.map(&:yellow)
