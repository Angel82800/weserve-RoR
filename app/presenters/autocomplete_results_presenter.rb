class AutocompleteResultsPresenter
  attr_reader :projects, :tasks, :users

  def initialize(projects, tasks, users)
    @projects = projects
    @tasks = tasks
    @users = users
  end

  def results
    objects = []
    objects << present_projects
    objects << present_tasks
    objects << present_users
    objects.flatten.sort_by { |o| o[:title].underscore }
  end

  def to_json
    JSON.generate(results)
  end

  private

  def present_projects
    projects.map { |p| AutocompleteProjectPresenter.new(p).result }
  end

  def present_tasks
    tasks.map { |t| AutocompleteTaskPresenter.new(t).result }
  end

  def present_users
    users.map { |t| AutocompleteUserPresenter.new(t).result }
  end
end
