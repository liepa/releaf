source "http://rubygems.org"
require 'yaml'

config_file = File.expand_path('../config.yml', __FILE__)
unless File.exists?(config_file)
  puts "config.yml is missing"
  puts "see CONTRIBUTING.md"
  exit(1)
end

config = YAML.load_file(config_file)

# Declare your gem's dependencies in releaf.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# gems re-listed for correct dummy app working

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use debugger
# gem 'debugger'


case config["database"]["type"]
when 'mysql'
  gem 'mysql2', '~> 0.3.18', platform: :ruby
  gem 'jdbc-mysql', platform: :jruby
  gem 'activerecord-jdbc-adapter', platform: :jruby
when 'postgresql'
  gem 'pg'
end

group :documentation do
  gem 'yard'
  gem 'github-markdown', '>= 0.5.3'
  gem 'redcarpet', '>= 2.2.2'
  gem 'yard-activerecord', '~> 0.0.14'
end
