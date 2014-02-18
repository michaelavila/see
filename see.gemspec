spec = Gem::Specification.new do |s| 
  s.name = 'see'
  s.version = '0.0.2'
  s.author = 'Michael Avila'
  s.email = 'me@michaelavila.com'
  s.platform = Gem::Platform::RUBY
  s.summary = 'Project status for programmers'
  s.files = %w(
bin/see
lib/see.rb
  )
  s.require_paths << 'lib'
  s.has_rdoc = true
  s.bindir = 'bin'
  s.executables << 'see'
  s.add_runtime_dependency 'colorize'
  s.add_runtime_dependency 'travis'
  s.add_runtime_dependency 'octokit'
  s.add_runtime_dependency 'pivotal-tracker'
end
