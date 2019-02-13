require 'rails_helper'

feature "Share/Invite People to the Participate", js: true do
  context "As logged in user" do
    before do
      @user = FactoryGirl.create(:user, confirmed_at: Time.now)
      login_as(@user, :scope => :user, :run_callbacks => false)
      visit root_path
    end

    context "When click 'Start a project' button" do
      before do
        click_pseudo_link 'Start a Project'
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

          @invite_modal = find("div#projectInviteModal", visible: true)
        end

        scenario "Then you can see 'Share/Invite People to Particiapte' popup" do
          expect(@invite_modal).to be_visible
        end

        context "When you fill the email and invite the person" do
          before do
            @email = "new@email.com"
            @invite_modal.fill_in "email", with: @email
          end

          scenario "Then your invitation email has been sent to the person" do
            expect_any_instance_of(ActionMailer::MessageDelivery).to receive(:deliver_later)

            @invite_modal.find('input[name="commit"]').click
          end

          scenario "Then email sent message appeared" do
            allow_any_instance_of(ActionMailer::MessageDelivery).to receive(:deliver_later)

            @invite_modal.find('input[name="commit"]').click
            wait_for_ajax

            expect(@invite_modal).to have_content I18n.t('projects.send_project_email.success', email: @email)
          end
        end
      end
    end
  end
end
