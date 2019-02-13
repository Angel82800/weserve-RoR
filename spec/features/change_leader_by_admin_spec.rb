require 'rails_helper'

feature "Change leader by admin", js: true do
  before do
    users = FactoryGirl.create_list(:user, 2, confirmed_at: Time.now)
    @admin = FactoryGirl.create(:user, confirmed_at: Time.now, admin: true)
    @leader_user = users.first
    @another_user = users.last
    @project = FactoryGirl.create(:project, user: @leader_user)
    @membership = FactoryGirl.create(:team_membership, team_member_id: @another_user.id, team_id: @project.team.id, role: 0)
  end

  context "Change leader" do
    before do
      login_as(@admin, :scope => :user, :run_callbacks => false)
      visit taskstab_project_path(@project, tab: 'team')
      page.find(".change-leader-btn").click
      page.accept_alert
      @membership.reload
    end
    scenario "Change completed" do
      expect(@membership.role).to eq("leader")
    end
  end
end
