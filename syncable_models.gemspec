$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "syncable_models/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "syncable_models"
  s.version     = SyncableModels::VERSION
  s.authors     = ["Serafim Nenarokov"]
  s.email       = ["serafim.nenarokov@flant.ru"]
  s.homepage    = "https://github.com/flant/syncable_models"
  s.summary     = "Sync your models easily."
  s.description = "The gem provides tagged syncing functionality and API methods."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.required_ruby_version = '>= 2.1.0'

  # TODO: add double-ended versions
  s.add_dependency "rails", ">= 4.2.5"
  s.add_dependency "sqlite3"
  s.add_dependency "mysql2"
  s.add_dependency "rake"
  s.add_dependency 'travis', '>= 1.8.2'
  s.add_dependency "activerecord", "~> 4.2.5"
  s.add_dependency "activesupport", "~> 4.2.5"
  s.add_dependency "railties", "~> 4.2.5"
  s.add_dependency "faraday", "~> 0.9.2"
end
