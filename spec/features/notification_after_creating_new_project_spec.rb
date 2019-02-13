require 'rails_helper'

xfeature "Notification After Creating a New Project", js: true do
  context "As a logged in user" do
    before do
      @users = FactoryGirl.create_list(:user, 2, confirmed_at: Time.now)
      @user = @users.first
      @another_user = @users.last
      login_as(@user, :scope => :user, :run_callbacks => false)
    end

    context "When you visit the main page" do
      before do
        visit root_path
      end

      context "When you create a new project" do
        before do
          click_pseudo_link 'Start a Project'
          wait_for_ajax

          modal = find('div#startProjectModal', visible: true)
          @project = FactoryGirl.build(:project)

          modal.fill_in 'project[title]', with: @project.title
          modal.fill_in 'project[short_description]', with: @project.short_description
          modal.fill_in 'project[country]', with: @project.country
          modal.attach_file 'project[picture]', Rails.root + "spec/fixtures/photo.png"

          modal.click_button 'Create Project'

          wait_for_ajax

          @invite_modal = find('div#projectInviteModal', visible: true)

          @invite_modal.find("button.modal-default__close").click
        end

        scenario "Then a new notification has been created" do
          expect(@user.notifications.count).not_to be_zero
        end

        scenario "Then the notification creates an alert on the top menu" do
          expect(page).to have_selector(".btn-bell__counter")
        end

        scenario "Then the notification alert indicates the number of unread notifications" do
          expect(find(".btn-bell__counter").text).to eq @user.notifications.unread.count.to_s
        end

        context "When you navigate 'Notifications' page" do
          before do
            find(".notify-dropdown").click
            wait_for_ajax

            @dropdown = find(".b-dropdown", visible: true)

            @dropdown.find(".b-dropdown__link").click_link I18n.t('notifications.see_all_message')
          end

          scenario "Then you can see the notification" do
            expect(page).to have_content "#{I18n.t('projects.create_project.notification ')} #{@project.title}"
          end

          scenario "Then the number of unread notifications has been disappeared on the alert" do
            expect(page).not_to have_selector(".btn-bell__counter")
          end

          context "When another user creates his or her project" do
            before do
              @another_project = FactoryGirl.create(:project, user: @another_user)
            end

            scenario "Then you can see only your notifications" do
              expect(page).not_to have_content "#{@another_project.title}"
            end
          end

        end

        context 'project was archived' do
          before do
            @project.destroy

            find(".notify-dropdown").click
            wait_for_ajax

            dropdown = find(".b-dropdown", visible: true)

            dropdown.find(".b-dropdown__link").click_link I18n.t('notifications.see_all_message')
          end

          scenario "create project notification is still available" do
            expect(page).to have_content "#{I18n.t('projects.create_project.notification ')} #{@project.title}"
          end
        end
      end
    end
  end
end
