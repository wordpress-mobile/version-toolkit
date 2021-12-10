# frozen_string_literal: true

require 'octokit'
require_relative '../lib/github_repository'

test_repository = 'oguzkocer/version-test-bin'
test_label = 'bug'

client = Octokit::Client.new(access_token: ENV['VERSION_TOOLKIT_GITHUB_TOKEN'])
client.auto_paginate = true

repo = GithubRepository.new(client, test_repository)

#puts repo.submodule_commit_hash('trunk', 'gutenberg')

#repo.create_submodule_hash_update_commit('created_from_helper',
#                                                     'gutenberg',
#                                                     'fc8a7891f900aa67a859b28f01aeb4e24fbf9011',
#                                                     'Update gutenberg submodule hash')

#puts repo.branch_exists?('automated-gutenberg-update/for-pr-19104')
#repo.create_branch('test_branch_exists', 'a5e0699fc0414bc71ed3706ea8b66cb24479eb87')
#puts repo.branch_sha(repo.default_branch)

# 1. Preparation
# Get all submodule pull requests
# Get all client pull requests
# Find which submodule pull requests should be downstreamed - possibly using a label as a filter
# Create branch names for submodule pull requests to be downstreamed: "version-toolkit/#{submodule_name}/#{submodule_branch_name}" => BRANCH_NAMES_TO_DOWNSTREAM

# 2. Close client pull requests that are no longer automated
# From the client pull requests, find the ones that start with "version-toolkit/#{submodule_name}" => CLIENT_DOWNSTREAMED_BRANCH_NAMES
# Find branch names that are in CLIENT_DOWNSTREAMED_BRANCH_NAMES but not in BRANCH_NAMES_TO_DOWNSTREAM => CANDIDATE_CLIENT_PULL_REQUESTS_TO_CLOSE
# These pull requests are no longer automated and should be closed unless there are commits by other developers

# 3. Create new branches
# For any branch name that is in BRANCH_NAMES_TO_DOWNSTREAM and not in CLIENT_DOWNSTREAMED_BRANCH_NAMES, create a new branch in client based on the default branch

# 4. Create submodule update commits
# For every branch in BRANCH_NAMES_TO_DOWNSTREAM, create a submodule hash update commit with the hash from the corresponding submodule PR if necessary

# 5. Open pull requests
# For every branch in BRANCH_NAMES_TO_DOWNSTREAM, but not in CLIENT_DOWNSTREAMED_BRANCH_NAMES, create a new pull request
