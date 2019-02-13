require 'rails_helper'

feature "Project Title", js: true do
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

      visit project_path @project
    end

    scenario "Then you can't see the pencil icon beside the project title" do
      expect(page).not_to have_selector("#title-pencil")
    end
  end

  context "When you visit the project page as the project manager" do
    before do
      login_as(@current_user, :scope => :user, :run_callbacks => false)

      visit project_path @project
    end

    scenario "Then you can see the pencil icon beside the project title" do
      expect(page).to have_selector("#title-pencil")
    end

    context "When you click the pencil icon bside the project title" do
      before do
        find("#title-pencil").trigger("click")

        @edit_form = find(".form_in_place", visible: true)
      end

      scenario "Then the edit form appeared" do
        expect(@edit_form).to be_visible
      end

      context "When you edit the title and click the 'Save' button" do
        before do
          @new_title = "new title"
          @edit_form.fill_in "title", with: @new_title

          # save_screenshot("file1.png", full: true)

          @edit_form.find('input[type="submit"]').click
        end

        # scenario "Then the project title has been changed" do
        #   expect(page.find(".b-project-info__title")).to have_content @new_title
        # end
      end
    end
  end

  context "When you visit the project page as the admin" do
    before do
      login_as(@admin, :scope => :user, :run_callbacks => false)

      visit project_path @project
    end

    scenario "Then you can see the pencil icon beside the project title" do
      expect(page).to have_selector("#title-pencil")
    end

    context "When you click the pencil icon bside the project title" do
      before do
        find("#title-pencil").trigger("click")

        @edit_form = find(".form_in_place", visible: true)
      end

      scenario "Then the edit form appeared" do
        expect(@edit_form).to be_visible
      end

      context "When you edit the title and click the 'Save' button" do
        before do
          @new_title = "new title"
          @edit_form.fill_in "title", with: @new_title

          # save_screenshot("file1.png", full: true)

          @edit_form.find('input[type="submit"]').click
        end

        # scenario "Then the project title has been changed" do
        #   expect(page.find(".b-project-info__title")).to have_content @new_title
        # end
      end
    end
  end
end
