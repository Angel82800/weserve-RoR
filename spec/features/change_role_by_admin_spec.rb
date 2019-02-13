require 'rails_helper'

feature "Change role by admin", js: true do
  before do
    users = FactoryGirl.create_list(:user, 2, confirmed_at: Time.now)
    @admin = FactoryGirl.create(:user, confirmed_at: Time.now, admin: true)
    @leader_user = users.first
    @another_user = users.last
    @project = FactoryGirl.create(:project, user: @leader_user)
    @membership = FactoryGirl.create(:team_membership, team_member_id: @another_user.id, team_id: @project.team.id, role: 0)
  end

  # context "Change role" do
  #   before do
  #     login_as(@admin, :scope => :user, :run_callbacks => false)
  #     visit taskstab_project_path(@project, tab: 'team')
  #     find("#user_role").trigger("click")
  #     select "Coordinator", from: "user_role"
  #     find(".change-role-btn").trigger("click")
  #     sleep 2
  #   end
  #   scenario "Change completed" do
  #     @membership.reload
  #     expect(@membership.role).to eq("coordinator")
  #   end
  # end
end
