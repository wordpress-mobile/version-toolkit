# frozen_string_literal: true

# Associated library & client PR information
class AssociatedPullRequest
  attr_reader :library_pr_title,
              :library_pr_body,
              :library_pr_head_ref,
              :client_pr_head_ref,
              :client_pr_number

  def initialize(library_pr, client_pr)
    set_library_pr(library_pr)
    set_client_pr(client_pr)
  end

  def add_library_pr!(library_pr)
    return unless library_pr

    @library_pr_title = library_pr.title
    @library_pr_body = library_pr.body
    @library_pr_head_ref = library_pr.head.ref

    verify_prs_are_associated(@library_pr_head_ref)
  end

  def add_client_pr!(client_pr)
    return unless client_pr

    @client_pr_head_ref = client_pr.head.ref
    @client_pr_number = client_pr.number
  end

  def verify_prs_are_associated
    return unless @library_pr_head_ref && @client_pr_head_ref

    branch_name = client_branch_name(@library_pr_head_ref)
    raise 'The library and client prs are not associated' if @client_pr_head_ref != branch_name
  end

  def client_branch_name(library_pr_head_ref)
    "#{BRANCH_NAME_PREFIX}/#{SUBMODULE_PATH}/#{library_pr_head_ref}"
  end
end
