# frozen_string_literal: true

require 'octokit'
require_relative '../lib/github_repository'

test_repository = 'oguzkocer/version-test-bin'
test_label = 'bug'

client = Octokit::Client.new(access_token: ENV['VERSION_TOOLKIT_GITHUB_TOKEN'])
client.auto_paginate = true

repo = GithubRepository.new(client, test_repository)

#repo.create_submodule_hash_update_commit('created_from_helper',
#                                                     'gutenberg',
#                                                     'fc8a7891f900aa67a859b28f01aeb4e24fbf9011',
#                                                     'Update gutenberg submodule hash')

#puts repo.branch_exists?('automated-gutenberg-update/for-pr-19104')
#repo.create_branch('test_branch_exists', 'a5e0699fc0414bc71ed3706ea8b66cb24479eb87')
#puts repo.branch_sha(repo.default_branch)
