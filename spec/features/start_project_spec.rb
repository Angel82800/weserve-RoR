require 'rails_helper'

feature "Start project", js: true do
  context "As logged in user" do
    before do
      @user = FactoryGirl.create(:user, confirmed_at: Time.now)
      login_as(@user, :scope => :user, :run_callbacks => false)
      visit root_path
    end

    context "When click 'Start a project' button" do
      before do
        click_pseudo_link I18n.t('commons.start_a_project')
        @modal = find('div#startProjectModal', visible: true)
      end

      scenario "Then 'Start New Project' popup appeared" do
        expect(@modal).to be_visible
      end

      context "When fill the fields and click 'Create Project' button" do
        before do
          @project = FactoryGirl.build(:project)
          @before_count = Project.count
          @modal.fill_in 'project[title]', with: @project.title
          @modal.fill_in 'project[short_description]', with: @project.short_description
          @modal.fill_in 'project[country]', with: @project.country
          @modal.attach_file 'project[picture]', Rails.root + "spec/fixtures/photo.png"

          @modal.click_button 'Create Project'
          wait_for_ajax
        end

        scenario "Then new project is created" do
          expect(Project.count).not_to eq @before_count
        end

        scenario "Then you are redirected to the project page" do
          project = Project.find_by_title(@project.title)

          expect(page).to have_current_path taskstab_project_path(project)
        end

        scenario "Then the project page contains information you entered" do
          expect(page).to have_content @project.title
          expect(page).to have_content @project.short_description
          expect(page).to have_content @project.country
        end
      end
    end
  end
end
