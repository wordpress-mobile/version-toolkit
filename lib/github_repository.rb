# frozen_string_literal: true

require 'octokit'
require 'json'

CREATE_TREE_MODE_SUBMODULE_COMMIT = '160000'
CREATE_TREE_TYPE_COMMIT = 'commit'

ERROR_MESSAGE_BRANCH_NOT_FOUND = 'Branch not found'

# Set of helper methods to interact with a single Github repository
class GithubRepository
  def initialize(client, repo)
    @client = client
    @repo = repo
  end

  def open_pull_requests
    @client.pull_requests(@repo, state: 'open')
  end

  def branch_names
    branches = @client.branches(@repo)
    branches.map(&:name)
  end

  def branch_exists?(branch_name)
    @client.branch(@repo, branch_name)
    # If no exception is raised, the branch exists
    true
  rescue Octokit::Error => e
    return false if e.response_status == 404 && JSON.parse(e.response_body)['message'] == ERROR_MESSAGE_BRANCH_NOT_FOUND

    raise
  end

  def create_branch(branch_name, sha)
    @client.create_ref(@repo, "heads/#{branch_name}", sha) unless branch_exists?(branch_name)
  end

  def create_branch_from_default_branch(branch_name)
    create_branch(branch_name, branch_sha(default_branch))
  end

  def default_branch
    @client.repository(@repo).default_branch
  end

  def branch_sha(branch_name)
    @client.ref(@repo, "heads/#{branch_name}").object.sha
  end

  def create_submodule_hash_update_commit(branch_name, submodule_path, new_submodule_hash, commit_message)
    parent_sha = branch_sha(branch_name)
    tree_sha = create_submodule_hash_update_tree(parent_sha, submodule_path, new_submodule_hash)
    new_commit_sha = create_standalone_commit(commit_message, tree_sha, parent_sha)
    @client.update_ref(@repo, "heads/#{branch_name}", new_commit_sha, false).object.sha
  end

  def create_standalone_commit(commit_message, tree, parent_sha)
    commit = @client.create_commit(@repo, commit_message, tree, parent_sha)
    commit.sha
  end

  def create_submodule_hash_update_tree(base_tree, submodule_path, new_submodule_hash)
    tree = @client.create_tree(@repo, [{
                                 path: submodule_path,
                                 mode: CREATE_TREE_MODE_SUBMODULE_COMMIT,
                                 type: CREATE_TREE_TYPE_COMMIT,
                                 sha: new_submodule_hash
                               }],
                               base_tree: base_tree)
    tree.sha
  end

  def submodule_commit_hash(branch_name, submodule_path)
    @client.contents(@repo, path: submodule_path, ref: branch_name).sha
  end

  def create_pull_request(head_branch, title, body)
    base_branch = default_branch
    @client.create_pull_request(@repo, base_branch, head_branch, title, body)
  end

  def close_pull_request(number)
    @client.close_pull_request(@repo, number)
  end
end
