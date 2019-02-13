require 'rails_helper'

RSpec.describe AutocompleteProjectPresenter do
  let(:project_id) { 555 }
  let(:project) { build(:project, id: project_id) }

  it "returns presented project" do
    presenter = described_class.new(project)
    result = presenter.result

    expect(result).to eq({
      type: 'project',
      id: project.id,
      title: project.title,
      path: "/projects/#{project.id}"
    })
  end
end
