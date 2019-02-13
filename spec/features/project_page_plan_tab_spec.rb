require 'rails_helper'

feature "Project Page Plan Tab", js: true do
  before do
    users = FactoryGirl.create_list(:user, 2, confirmed_at: Time.now)
    @user = users.first
    @regular_user = users.last
    @project = FactoryGirl.create(:project, user: @user)
    @task = FactoryGirl.create(:task, project: @project)
  end

  context "As project leader" do
    before do
      login_as(@user, :scope => :user, :run_callbacks => false)
    end

    context "When you visit the project page" do
      before do
        visit project_path(@project)
        @plan_area = find(".tabs-wrapper__plan")
        @button_tabs = find(".project-btn-group")
        @revision_button = find("#editSource")
      end

      scenario "Then you can see 'Revisions' button" do
        expect(@plan_area).to have_selector("#editSource")
      end

      scenario "Then you can see 'Edit' button" do
        expect(@plan_area).to have_link "Edit"
      end
    end
  end

  context "As regular user" do
    before do
      login_as(@regular_user, :scope => :user, :run_callbacks => false)
    end

    context "When you visit the project page" do
      before do
        visit project_path(@project)
        @plan_area = find(".tabs-wrapper__plan")
      end

      scenario "Then you cannot see 'Revisions' button" do
        expect(@plan_area).not_to have_selector("#editSource")
      end

      scenario "Then you can see 'Edit' button" do
        expect(@plan_area).to have_link "Edit"
      end
    end
  end

  context "As anonymous user" do
    context "When you visit the project page" do
      before do
        visit project_path(@project)
        @plan_area = find(".tabs-wrapper__plan")
      end

      scenario "Then you cannot see 'Revisions' button" do
        expect(@plan_area).not_to have_selector("#editSource")
      end

      scenario "Then you can see 'Edit' button" do
        expect(@plan_area).to have_selector ".btn-edit-wrapper a"
      end

      context "When you click 'Edit' button" do
        before do
          @plan_area.find(".btn-edit-wrapper a").trigger("click")
          wait_for_ajax
        end

        scenario "Then the 'Sign in' modal appeared" do
          modal = find('div#registerModal', visible: true)
          expect(modal).to be_visible
        end
      end
    end
  end
end
