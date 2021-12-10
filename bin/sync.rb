# frozen_string_literal: true

require 'octokit'
require 'json'
require_relative '../lib/submodule_update_flow'
require_relative '../lib/github_repository'

client = Octokit::Client.new(access_token: ENV['VERSION_TOOLKIT_GITHUB_TOKEN'])
client.auto_paginate = true

JSON.parse(File.read('./config.json')).each do |child|
  SubmoduleUpdateFlow.new(child['client_repo'],
                          child['submodule_repo'],
                          child['submodule_path'],
                          child['filter_label'],
                          client).sync
end
