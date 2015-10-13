# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'alerter/version'

Gem::Specification.new do |s|
  s.name = "alerter"
  s.version = Alerter::VERSION

  s.authors = ["Michael Kazmier"]
  s.summary = "Messaging system for rails apps."
  s.description = "Many apps need to pass basic notifications between objects and/or users, often using multiple " +
      "delivery methods (like email, push notifications, SMS, twitter, etc).  This gem is designed to " +
      "make that process easy and track the state of the notification in a centralized fashion."
  s.email = [ "dakazmier@gmail.com" ]
  s.homepage = ""
  s.files = `git ls-files`.split("\n")
  s.license = 'MIT'

  # Gem dependencies
  #
  # SQL foreign keys
  s.add_runtime_dependency('foreigner', '>= 0.9.1')

  # Development Gem dependencies
  s.add_runtime_dependency('rails', '>= 3.2.0')

  if RUBY_ENGINE == "rbx" && RUBY_VERSION >= "2.1.0"
    # Rubinius has it's own dependencies
    s.add_runtime_dependency     'rubysl'
    s.add_development_dependency 'racc'
  end
  # Specs
  s.add_development_dependency 'pry'
  s.add_development_dependency 'pry-rails'
  s.add_development_dependency 'rspec-rails', '~> 3.0'
  s.add_development_dependency 'rspec-its', '~> 1.1'
  s.add_development_dependency 'rspec-collection_matchers', '~> 1.1'
  s.add_development_dependency('appraisal', '~> 1.0.0')
  s.add_development_dependency('shoulda-matchers')
  # Fixtures
  #if RUBY_VERSION >= '1.9.2'
  # s.add_development_dependency('factory_girl', '>= 3.0.0')
  #else
  #s.add_development_dependency('factory_girl', '~> 2.6.0')
  #end
  s.add_development_dependency('factory_girl', '~> 3.3.0')
  # Population
  s.add_development_dependency('forgery', '>= 0.3.6')
  # Integration testing
  s.add_development_dependency('capybara', '>= 0.3.9')
  # Testing database
  if RUBY_PLATFORM == 'java'
    s.add_development_dependency('jdbc-sqlite3')
    s.add_development_dependency('activerecord-jdbcsqlite3-adapter', '1.3.0.rc1')
  else
    s.add_development_dependency('sqlite3')
  end
end