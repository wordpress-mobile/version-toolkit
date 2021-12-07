# frozen_string_literal: true

require 'octokit'
require_relative '../lib/Helper.rb'

test_repository = 'oguzkocer/version-test-bin'
test_label = 'bug'

client = Octokit::Client.new(access_token: ENV['VERSION_TOOLKIT_GITHUB_TOKEN'])
client.auto_paginate = true

test_repo_helper = Helper.new(client, test_repository)

#puts test_repo_helper.get_branch_names()
#puts test_repo_helper.pull_requests_with_label(test_label)

#sha = test_repo_helper.default_branch_sha()
#test_repo_helper.create_branch(sha)
