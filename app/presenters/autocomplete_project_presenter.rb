class AutocompleteProjectPresenter < ApplicationPresenter
  attr_reader :project

  def initialize(project)
    @project = project
  end

  def result
    {
      type: 'project',
      id: project.id,
      title: project.title || '',
      path: path
    }
  end

  private

  def path
    url_helpers.project_path(project.id)
  end
end
