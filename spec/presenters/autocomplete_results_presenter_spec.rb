require 'rails_helper'

RSpec.describe AutocompleteResultsPresenter do
  let(:projects) { create_list(:project, 2) }
  let(:tasks) { create_list(:task, 3, project_id: projects.first.id) }
  let(:users) { create_list(:user, 2) }

  describe "#results" do
    it "returns an array of presented objects" do
      presenter = described_class.new(projects, tasks, users)
      results = presenter.results

      expect(results.size).to eq(projects.size + tasks.size + users.size)
      expect(results.count { |r| r[:type] == 'project' }).to eq(projects.size)
      expect(results.count { |r| r[:type] == 'task' }).to eq(tasks.size)
      expect(results.count { |r| r[:type] == 'user' }).to eq(users.size)
    end

    it "returns an empty array when no matches found" do
      presenter = described_class.new([], [], [])
      results = presenter.results

      expect(results.size).to eq(0)
    end
  end

  describe "#to_json" do
    it "returns a json" do
      presenter = described_class.new(projects, tasks, users)
      json = presenter.to_json

      expect(json).to be_present
      expect(JSON.parse(json).size).to eq(projects.size + tasks.size + users.size)
    end

    it "returns a json with an empty array when no matches found" do
      presenter = described_class.new([], [], [])
      json = presenter.to_json

      expect(json).to eq("[]")
    end
  end
end
