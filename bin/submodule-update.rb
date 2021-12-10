# frozen_string_literal: true

require 'octokit'
require_relative '../lib/github_repository'

BRANCH_NAME_PREFIX = 'version-toolkit'
SUBMODULE_REPOSITORY_NAME = 'wordpress/gutenberg'
SUBMODULE_PATH = 'gutenberg'
CLIENT_REPOSITORY_NAME = 'oguzkocer/version-test-bin'
FILTER_LABEL = 'Mobile App - i.e. Android or iOS'

def client_branch_name_for_submodule_pr(submodule_pr)
  "#{BRANCH_NAME_PREFIX}/#{SUBMODULE_PATH}/#{submodule_pr.head.ref}"
end

client = Octokit::Client.new(access_token: ENV['VERSION_TOOLKIT_GITHUB_TOKEN'])
client.auto_paginate = true

# 1. Preparation
# Get all submodule pull requests
# Get all client pull requests
submodule_repo = GithubRepository.new(client, SUBMODULE_REPOSITORY_NAME)
client_repo = GithubRepository.new(client, CLIENT_REPOSITORY_NAME)
submodule_prs = submodule_repo.open_pull_requests()
client_prs = client_repo.open_pull_requests()

# Find which submodule pull requests should be downstreamed
submodule_prs_to_downstream = submodule_prs.filter do |pr|
  !pr.fork && pr.labels.any? do |label|
    label.name == FILTER_LABEL
  end
end

# Create branch names for submodule pull requests to be downstreamed: "version-toolkit/#{submodule_name}/#{submodule_branch_name}" => BRANCH_NAMES_TO_DOWNSTREAM
branch_names_to_downstream = submodule_prs_to_downstream.map do |pr|
  client_branch_name_for_submodule_pr(pr)
end

# 2. Close client pull requests that are no longer automated
# From the client pull requests, find the ones that start with "version-toolkit/#{submodule_name}" => CLIENT_DOWNSTREAMED_BRANCH_NAMES
# Find branch names that are in CLIENT_DOWNSTREAMED_BRANCH_NAMES but not in BRANCH_NAMES_TO_DOWNSTREAM => CANDIDATE_CLIENT_PULL_REQUESTS_TO_CLOSE
# These pull requests are no longer automated and should be closed unless there are commits by other developers
client_downstreamed_branch_names = client_prs.filter do |pr|
  pr.head.ref.start_with?(BRANCH_NAME_PREFIX)
end

candidate_client_pull_requests_to_close = client_downstreamed_branch_names - branch_names_to_downstream

# 3. Create new branches
# For any branch name that is in BRANCH_NAMES_TO_DOWNSTREAM and not in CLIENT_DOWNSTREAMED_BRANCH_NAMES, create a new branch in client based on the default branch
(branch_names_to_downstream - client_downstreamed_branch_names).each do |branch_name|
  client_repo.create_branch_from_default_branch(branch_name)
end

# 4. Create submodule update commits
# For every PR in SUBMODULE_PRS_TO_DOWNSTREAM, create a submodule hash update commit with the hash from the corresponding submodule PR if necessary
submodule_prs_to_downstream.each do |submodule_pr|
  client_branch_name = client_branch_name_for_submodule_pr(submodule_pr)
  submodule_pr_commit_hash = submodule_pr.head.sha
  if client_repo.submodule_commit_hash(client_branch_name, SUBMODULE_PATH) != submodule_pr_commit_hash
    client_repo.create_submodule_hash_update_commit(client_branch_name,
                                             SUBMODULE_PATH,
                                             submodule_pr_commit_hash,
                                             "Update #{SUBMODULE_PATH} submodule hash to #{submodule_pr_commit_hash}")
  end
end

# 5. Open pull requests
# For every branch in BRANCH_NAMES_TO_DOWNSTREAM, but not in CLIENT_DOWNSTREAMED_BRANCH_NAMES, create a new pull request

