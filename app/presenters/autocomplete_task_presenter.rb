class AutocompleteTaskPresenter < ApplicationPresenter
  attr_reader :task

  def initialize(task)
    @task = task
  end

  def result
    {
      type: 'task',
      id: task.id,
      title: task.title || '',
      path: path
    }
  end

  private

  def path
    url_helpers.taskstab_project_path(task.project_id, tab: 'tasks',
                                                       taskId: task.id)
  end
end
