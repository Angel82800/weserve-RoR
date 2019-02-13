require 'rails_helper'

RSpec.describe ProjectDescriptionsUpdater do
  let(:owner) { FactoryGirl.create(:user, confirmed_at: Time.now) }

  describe '#sync_project' do
    let(:project) { FactoryGirl.create(:project, user: owner) }

    it 'updates full_description from the latest revision' do
      mock_mediawiki_response!(project: project, text: 'foobar')

      described_class.sync_project(project)
      expect(project.full_description).to eq('foobar')
    end
  end

  describe '#sync_all_projects' do
    let(:count) { 3 }
    let(:projects) { FactoryGirl.create_list(:project, count, user: owner) }

    it 'invokes sync_project for all existing projects in DB' do
      projects.each do |project|
        expect(described_class).to receive(:sync_project).with(project)
        mock_mediawiki_response!(project: project, text: 'foobar')
      end

      described_class.sync_all_projects
    end
  end

  private
  def mock_mediawiki_response!(project:, text:)
    allow(project).to receive(:get_latest_revision).and_return(text)
  end
end
