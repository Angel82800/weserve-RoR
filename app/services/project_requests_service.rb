class ProjectRequestsService
  attr_reader :project

  def initialize(project)
    @project = project
  end

  def requests_count
     pending_requests_count + resolved_requests_count
  end

  def pending_requests_count
    pending_do_requests.count + pending_apply_requests.count
  end

  def resolved_requests_count
    resolved_do_requests.count + resolved_apply_requests.count
  end

  def pending_do_requests
    DoRequest.pending.where(project_id: @project.id)
  end

  def pending_apply_requests
    ApplyRequest.pending.where(project_id: @project.id)
  end

  def resolved_do_requests
    DoRequest.where(
      project_id: @project.id,
      state: %w(rejected accepted)
    )
  end

  def resolved_apply_requests
    ApplyRequest.where(project_id: @project.id).select{|ar| !ar.is_valid?}
  end
end
