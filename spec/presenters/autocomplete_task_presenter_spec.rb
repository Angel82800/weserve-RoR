require 'rails_helper'

RSpec.describe AutocompleteTaskPresenter do
  let(:task_id) { 333 }
  let(:project_id) { 222 }
  let(:task) { build(:task, id: task_id, project_id: project_id) }

  it "returns presented task" do
    presenter = described_class.new(task)
    result = presenter.result

    expect(result).to eq({
      type: 'task',
      id: task.id,
      title: task.title,
      path: "/projects/#{task.project_id}/taskstab?tab=tasks&taskId=#{task.id}"
    })
  end
end
