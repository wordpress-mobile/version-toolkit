# frozen_string_literal: true

require 'rubocop/rake_task'

task :run do
  ENV['RUBYOPT'] = '-W0'
  ruby 'bin/main.rb'
end

task :submodule_update do
  ENV['RUBYOPT'] = '-W0'
  ruby 'bin/submodule-update.rb'
end

RuboCop::RakeTask.new
