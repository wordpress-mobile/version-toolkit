# frozen_string_literal: true

require 'octokit'
require_relative '../lib/submodule_update_flow'
require_relative '../lib/github_repository'

BRANCH_NAME_PREFIX = 'version-toolkit'
SUBMODULE_REPOSITORY_NAME = 'wordpress/gutenberg'
SUBMODULE_PATH = 'gutenberg'
CLIENT_REPOSITORY_NAME = 'oguzkocer/version-test-bin'
#FILTER_LABEL = 'Mobile App - i.e. Android or iOS'
FILTER_LABEL = '[Block] Table'

client = Octokit::Client.new(access_token: ENV['VERSION_TOOLKIT_GITHUB_TOKEN'])
client.auto_paginate = true
flow = SubmoduleUpdateFlow.new(CLIENT_REPOSITORY_NAME,
                               SUBMODULE_REPOSITORY_NAME,
                               SUBMODULE_PATH,
                               FILTER_LABEL,
                               client)
flow.sync()
