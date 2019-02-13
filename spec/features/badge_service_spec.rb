require 'rails_helper'

RSpec.describe BadgeService do
  let(:project) { FactoryGirl.create(:project) }
  let(:user) { project.user }

  describe '#assign badge' do
    it 'should create donor badge' do
      BadgeService.assign_donor(project, user)
      expect(Badge.count).to eq 1
      expect(Badge.last.project).to eq project
      expect(Badge.last.user).to eq user
      expect(Badge.last.badge_type).to eq 'donor'
    end
  end
end
