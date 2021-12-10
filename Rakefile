# frozen_string_literal: true

require 'rubocop/rake_task'

task :run do
  ENV['RUBYOPT'] = '-W0'
  ruby 'bin/main.rb'
end

RuboCop::RakeTask.new
