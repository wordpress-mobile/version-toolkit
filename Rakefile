# frozen_string_literal: true

require 'rubocop/rake_task'

task :sync do
  ENV['RUBYOPT'] = '-W0'
  ruby 'bin/sync.rb'
end

RuboCop::RakeTask.new
