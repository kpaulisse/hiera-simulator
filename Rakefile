require 'rubygems'
require 'bundler/setup'

require 'bundler'
Bundler::GemHelper.install_tasks

task :default do
  Rake::Task['spec'].invoke
end

desc 'Run all hiera-simulator gem specs'
task :spec do
  exec 'rspec -c spec'
end
