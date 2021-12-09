# frozen_string_literal: true

require 'octokit'

CREATE_TREE_MODE_SUBMODULE_COMMIT = '160000'
CREATE_TREE_TYPE_COMMIT = 'commit'

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

  def create_branch(branch_name, sha)
    @client.create_ref(@repo, branch_name, sha)
  end

  def default_branch_sha()
    return branch_sha("heads/trunk")
  end

  def branch_sha(branch)
    return @client.ref(@repo, branch).object.sha
  end

  def create_submodule_hash_update_commit(branch, submodule_path, new_submodule_hash, commit_message)
    parent_sha = branch_sha(branch)
    tree_sha = create_submodule_hash_update_tree(parent_sha, submodule_path, new_submodule_hash)
    new_commit_sha = create_standalone_commit(commit_message, tree_sha, parent_sha)
    return @client.update_ref(@repo, branch, new_commit_sha, false).object.sha
  end

  def create_standalone_commit(commit_message, tree, parent_sha)
    commit = @client.create_commit(@repo, commit_message, tree, parent_sha)
    return commit.sha
  end

  def create_submodule_hash_update_tree(base_tree, submodule_path, new_submodule_hash)
    tree = @client.create_tree(@repo, [{
      :path => submodule_path,
      :mode => CREATE_TREE_MODE_SUBMODULE_COMMIT,
      :type => CREATE_TREE_TYPE_COMMIT,
      :sha => new_submodule_hash
    }],
      :base_tree => base_tree,
    )
    return tree.sha
  end
end
