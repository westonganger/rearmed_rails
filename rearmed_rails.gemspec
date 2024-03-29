lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rearmed_rails/version.rb'

Gem::Specification.new do |s|
  s.name        = 'rearmed_rails'
  s.version     =  RearmedRails::VERSION
  s.author	= "Weston Ganger"
  s.email       = 'weston@westonganger.com'
  s.homepage 	= 'https://github.com/westonganger/rearmed_rails'
  
  s.summary     = "A collection of helpful methods and monkey patches for Rails"
  s.description = s.summary
  s.files = Dir.glob("{lib/**/*}") + %w{ LICENSE README.md Rakefile CHANGELOG.md }

  s.add_development_dependency 'rake'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'wwtd'

  s.required_ruby_version = '>= 1.9.3'
  s.require_path = 'lib'
end
