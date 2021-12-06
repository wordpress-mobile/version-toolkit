# frozen_string_literal: true

require 'octokit'

client = Octokit::Client.new(access_token: ENV['VERSION_TOOLKIT_GITHUB_TOKEN'])
client.auto_paginate = true
