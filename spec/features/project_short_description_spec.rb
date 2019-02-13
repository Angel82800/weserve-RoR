require 'rails_helper'

feature "Project Short Description", js: true do
  before do
    users = FactoryGirl.create_list(:user, 2, confirmed_at: Time.now)
    @current_user = users.first
    @another_user = users.last
    @admin = FactoryGirl.create(:user, confirmed_at: Time.now, admin: true)
    @project = FactoryGirl.create(:project, user: @current_user)
  end

  context "When you visit the project page as user" do
    before do
      login_as(@another_user, :scope => :user, :run_callbacks => false)

      visit taskstab_project_path(@project, tab: 'plan')
    end

    scenario "Then you can't edit the short description" do
      expect(page).not_to have_selector("#sd_pencil")
    end
  end

  context "When you visit the project page as the project manager" do
    before do
      login_as(@current_user, :scope => :user, :run_callbacks => false)

      visit taskstab_project_path(@project, tab: 'plan')
    end

    scenario "Then you can edit the project short description" do
      expect(page).to have_selector("#sd_pencil")
    end

    context "When you click the project short description" do
      before do
        find("#sd_pencil").trigger("click")

        @edit_form = find(".form_in_place", visible: true)
      end

      scenario "Then the edit form appeared" do
        expect(@edit_form).to be_visible
      end

      context "When you edit the description and click the 'Save' button" do
        before do
          @new_description = "new description"
          @edit_form.fill_in "short_description", with: @new_description

          # save_screenshot("file1.png", full: true)

          @edit_form.find('input[type="submit"]').click
        end

        # scenario "Then the project title has been changed" do
        #   expect(page.find("#best_in_place_project_1_short_description")).to have_content @new_description
        # end
      end
    end
  end

  context "When you visit the project page as the admin" do
    before do
      login_as(@admin, :scope => :user, :run_callbacks => false)

      visit taskstab_project_path(@project, tab: 'plan')
    end

    scenario "Then you can edit the project short description" do
      expect(page).to have_selector("#sd_pencil")
    end

    context "When you click the project short description" do
      before do
        find("#sd_pencil").trigger("click")

        @edit_form = find(".form_in_place", visible: true)
      end

      scenario "Then the edit form appeared" do
        expect(@edit_form).to be_visible
      end

      context "When you edit the description and click the 'Save' button" do
        before do
          @new_description = "new description"
          @edit_form.fill_in "short_description", with: @new_description

          # save_screenshot("file1.png", full: true)

          @edit_form.find('input[type="submit"]').click
        end

        # scenario "Then the project title has been changed" do
        #   expect(page.find("#best_in_place_project_1_short_description")).to have_content @new_description
        # end
      end
    end
  end
end
