# frozen_string_literal: true

require 'octokit'
require_relative '../lib/Helper'

test_repository = 'oguzkocer/version-test-bin'
test_label = 'bug'

client = Octokit::Client.new(access_token: ENV['VERSION_TOOLKIT_GITHUB_TOKEN'])
client.auto_paginate = true

test_repo_helper = Helper.new(client, test_repository)

test_repo_helper.create_submodule_hash_update_commit('heads/created_from_helper',
                                                     'gutenberg',
                                                     'fc8a7891f900aa67a859b28f01aeb4e24fbf9011',
                                                     'Update gutenberg submodule hash')
