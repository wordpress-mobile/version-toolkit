# frozen_string_literal: true

GLOBAL_BRANCH_NAME_PREFIX = 'version-toolkit'

# A flow that creates/updates client PRs for the given submodule PRs on `sync`
class SubmoduleUpdateFlow
  def initialize(client_repository_name, submodule_repository_name, submodule_path, filter_label, client)
    @client_repository_name = client_repository_name
    @submodule_repository_name = submodule_repository_name
    @submodule_path = submodule_path
    @filter_label = filter_label

    @submodule_repo = GithubRepository.new(client, @submodule_repository_name)
    @client_repo = GithubRepository.new(client, @client_repository_name)
  end

  def sync
    close_outdated_pull_requests
    create_client_branches
    update_client_branches_with_new_submodule_hash
    open_pull_requests
  end

  # Find client PRs that no longer has an associated submodule PR and close them unless there are other changes
  def close_outdated_pull_requests
    puts "Closing #{prs_to_close.length} pull request(s) that no longer has an associated submodule pull request.."

    prs_to_close.each do |_, pr|
      @client_repo.add_comment(pr.number, close_pull_request_comment)
      @client_repo.close_pull_request(pr.number)
      @client_repo.delete_branch(pr.head.ref)
    end
  end

  private

  def candidate_prs_to_close
    automated_clients_prs.filter do |branch_name, _|
      !submodule_prs_to_downstream.key?(branch_name)
    end
  end

  # If there are changes by other developers or if it's assigned, don't close the PR
  def prs_to_close
    candidate_prs_to_close.filter do |_, pr|
      has_other_commits = pr_has_other_commits?(pr.number)
      puts "PR ##{pr.number} has commits by other developers, skipping.." if has_other_commits

      is_assigned = !pr.assignees.empty?
      puts "PR ##{pr.number} is assigned to #{pr.assignees.map(&:login)}, skipping.." if is_assigned

      !has_other_commits && !is_assigned
    end
  end

  def pr_has_other_commits?(pr_number)
    @client_repo.pull_commits(pr_number).any? do |commit|
      commit.author.login != 'wpmobilebot'
    end
  end

  # Creates a submodule hash update commit for client branches
  def update_client_branches_with_new_submodule_hash
    puts 'Creating commits for each submodule PR..'
    submodule_prs_to_downstream.each do |client_branch_name, submodule_pr|
      submodule_pr_commit_hash = submodule_pr.head.sha
      # Already has the correct commit hash
      next unless @client_repo.submodule_commit_hash(client_branch_name, @submodule_path) != submodule_pr_commit_hash

      commit_message = "Update #{@submodule_path} submodule hash to #{submodule_pr_commit_hash}"
      @client_repo.create_submodule_hash_update_commit(client_branch_name,
                                                       @submodule_path,
                                                       submodule_pr_commit_hash,
                                                       commit_message)
    end
  end

  # Opens a client PR if there isn't already an associated PR
  def open_pull_requests
    prs = submodule_prs_to_downstream.filter do |branch_name, _|
      !automated_clients_prs.key?(branch_name)
    end
    puts "Opening #{prs.length} pull request(s).."
    prs.each do |branch_name, submodule_pr|
      @client_repo.create_pull_request(branch_name,
                                       submodule_pr.title,
                                       new_pull_request_body(submodule_pr.html_url, submodule_pr.user.login))
    end
  end

  # Create a branch for each submodule PR that don't already have an associated client PR
  def create_client_branches
    puts 'Creating new branches...'
    (submodule_prs_to_downstream.keys - automated_clients_prs.keys).each do |branch_name|
      @client_repo.create_branch_from_default_branch(branch_name)
    end
  end

  def submodule_prs_to_downstream
    @submodule_prs_to_downstream ||= fetch_submodule_prs_to_downstream
  end

  def automated_clients_prs
    @automated_clients_prs ||= fetch_automated_clients_prs
  end

  # Fetches submodule PRs and filters it to find the ones to be downstreamed
  def fetch_submodule_prs_to_downstream
    puts "Fetching #{@submodule_repository_name} pull requests.."
    prs = @submodule_repo.open_pull_requests.filter do |pr|
      !pr.fork && pr.labels.any? do |label|
        label.name == @filter_label
      end
    end
    puts "Found #{prs.length} #{@submodule_repository_name} pull request(s) to automate"
    prs.to_h { |pr| [client_branch_name_for_submodule_pr(pr), pr] }
  end

  # Fetches client PRs and filters it to find the ones that are automated
  def fetch_automated_clients_prs
    puts "Fetching #{@client_repository_name} pull requests..."
    prs = @client_repo.open_pull_requests.filter do |pr|
      pr.head.ref.start_with?(branch_name_prefix)
    end
    puts "Found #{prs.length} pull request(s) automated by us"
    prs.to_h { |pr| [pr.head.ref, pr] }
  end

  def client_branch_name_for_submodule_pr(submodule_pr)
    "#{branch_name_prefix}/#{submodule_pr.head.ref}"
  end

  def branch_name_prefix
    "#{GLOBAL_BRANCH_NAME_PREFIX}/#{@submodule_path}"
  end

  def new_pull_request_body(submodule_pr_url, submodule_pr_author)
    %(
## Related PRs

* #{submodule_pr_url} by @#{submodule_pr_author}

## Description

This PR is generated by `version-toolkit` to downstream the changes for `#{@submodule_path}` submodule.
    )
  end

  def close_pull_request_comment
    %(
This PR is closed because there is no longer an associated `#{@submodule_path}` PR for it.

If you'd like to keep a PR open after its upstream counterpart is closed, \
please assign it to a team member or create a new commit.
    )
  end
end
