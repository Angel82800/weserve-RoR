require 'rails_helper'

feature "Project Follow/Unfollow", js: true do

  context "As logged in user" do
    before do
      @users = FactoryGirl.create_list(:user, 2, confirmed_at: Time.now)
      @users.each do |user|
        @projects = FactoryGirl.create_list(:project, 2, user: user)
      end

      @current_user = @users.first
      @another_user = @users.last

      login_as(@current_user, :scope => :user, :run_callbacks => false)
      
      visit root_path
    end

    context "When you visit the project page that you are not manager of" do
      before do
        @project = @another_user.projects.first
        visit project_path(@project)
      end

      scenario "Then you can see 'Follow' button" do
        expect(find(".project-btn-group")).to have_content(I18n.t('commons.follow'))
      end

# TODO: disabled due bug in following projects
=begin
      context "When you click the 'Follow' button" do
        before do
          find(".project-btn-group").click_link "Follow"
          wait_for_ajax
        end

        scenario "Then the followed project has been added to your followed projects" do
          expect(@current_user.followed_projects.include?(@project)).to be true
        end

        context "When you visit the followed project page" do
          before do
            visit project_path(@project)
          end

          scenario "Then you can see 'Unfollow' button" do
            expect(find(".project-btn-group")).to have_content(I18n.t('commons.unfollow'))
          end

          context "When you click 'Unfollow' button" do
            before do
              find(".project-btn-group").click_link I18n.t('commons.unfollow')
            end

            scenario "Then the project has been removed from your followed projects" do
              expect(@current_user.followed_projects.include?(@project)).to be false
            end
          end
        end
      end
=end

    end
  end
end
