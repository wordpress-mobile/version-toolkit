# frozen_string_literal: true

require 'octokit'

class Helper
  def initialize(client, repo)
    @client = client
    @repo = repo
  end

  def pull_requests_with_label(label_name)
    pull_requests = @client.pull_requests(@repo).filter do |pr|
      pr.labels.any? do |label|
        label.name == label_name
      end
    end

    return pull_requests.map { |pr| "#{pr.title} - ##{pr.number}" }
  end

  def get_branch_names()
    branches = @client.branches(@repo)
    return branches.map { |branch| branch.name }
  end

  def create_branch(sha)
    @client.create_ref(@repo, "heads/created_from_helper", sha)
  end

  def default_branch_sha()
    return @client.ref(@repo, "heads/trunk").object.sha
  end
end
