require File.expand_path(File.dirname(__FILE__) + '/lib/rearmed_rails/version.rb')
require 'bundler/gem_tasks'

task :test do 
  require 'rake/testtask'
  Rake::TestTask.new do |t|
    t.libs << 'test'
    t.test_files = FileList['test/**/tc_*.rb']
    t.verbose = true
  end
end

task :console do
  require 'rearmed_rails'

  RearmedRails.enabled_patches = {
    rails: true,
    minitest: true
  }

  require 'rearmed_rails/apply_patches'

  require 'irb'
  binding.irb
end

task default: :test
