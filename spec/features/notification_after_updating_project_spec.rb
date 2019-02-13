require 'rails_helper'

xfeature "Notification After Updating the Project", js: true do
  context "As a logged in user who has been created the project" do
    before do
      @user = FactoryGirl.create(:user, confirmed_at: Time.now)
      @project = FactoryGirl.create(:project, user: @user)

      login_as(@user, :scope => :user, :run_callbacks => false)      
    end

    context "When you visit the project page" do
      before do
        visit project_path(@project)

        @notification_count = @user.notifications.count
        @alert_number = find(".btn-bell__counter").text.to_i
      end

      context "When you change the project title and reload the project page" do
        before do
          find("#title-pencil").trigger("click")
          @edit_form = find(".form_in_place", visible: true)

          @new_title = "new title"
          @edit_form.fill_in "title", with: @new_title

          @edit_form.find('input[type="submit"]').click
          wait_for_ajax

          visit project_path(@project)
        end

        scenario "Then a new notification has been created" do
          expect(@user.notifications.count).to eq @notification_count + 1
        end

        scenario "Then the notification increases the number of unread notifications on the top menu alert" do
          expect(find(".btn-bell__counter").text.to_i).to eq @alert_number + 1
        end

        context "When you navigate 'Notifications' page" do
          before do
            find(".notify-dropdown").click
            wait_for_ajax

            @dropdown = find(".b-dropdown", visible: true)

            @dropdown.find(".b-dropdown__link").click_link I18n.t('notifications.see_all_message')
          end

          scenario "Then you can see the notification" do
            expect(page).to have_content "#{I18n.t('projects.update_project.notification')} #{@new_title}"
          end
        end
      end

      context "When you change the project location and reload the project page" do
        before do
          find("#country-pencil").trigger("click")
          @edit_form = find(".form_in_place", visible: true)

          @new_location = "new location"
          @edit_form.fill_in "country", with: @new_location

          @edit_form.find('input[type="submit"]').click
          wait_for_ajax

          visit project_path(@project)
        end

        scenario "Then a new notification has been created" do
          expect(@user.notifications.count).to eq @notification_count + 1
        end

        scenario "Then the notification increases the number of unread notifications on the top menu alert" do
          expect(find(".btn-bell__counter").text.to_i).to eq @alert_number + 1
        end

        context "When you navigate 'Notifications' page" do
          before do
            find(".notify-dropdown").click
            wait_for_ajax

            @dropdown = find(".b-dropdown", visible: true)

            @dropdown.find(".b-dropdown__link").click_link I18n.t('notifications.see_all_message')
          end

          scenario "Then you can see the notification" do
            expect(page).to have_content "#{I18n.t('projects.update_project.notification')} #{@project.title}"
          end
        end
      end

      context "When you change the project image and reload the project page" do
        before do
          find('a.btn-edit.btn-edit-image').trigger("click") 
          @edit_form = find('div#project-img-edit', visible: true)

          @edit_form.attach_file 'project[picture]', Rails.root + "spec/fixtures/photo2.jpg"
          @edit_form.click_button "Save Changes"
          wait_for_ajax

          visit project_path(@project)
        end

        scenario "Then a new notification has been created" do
          expect(@user.notifications.count).to eq @notification_count + 1
        end

        scenario "Then the notification increases the number of unread notifications on the top menu alert" do
          expect(find(".btn-bell__counter").text.to_i).to eq @alert_number + 1
        end

        context "When you navigate 'Notifications' page" do
          before do
            find(".notify-dropdown").click
            wait_for_ajax

            @dropdown = find(".b-dropdown", visible: true)

            @dropdown.find(".b-dropdown__link").click_link I18n.t('notifications.see_all_message')
          end

          scenario "Then you can see the notification" do
            expect(page).to have_content "#{I18n.t('projects.update_project.notification')} #{@project.title}"
          end
        end
      end

      context "When you change the project short description and reload the project page" do
        before do
          find("#sd_pencil").trigger("click")
          @edit_form = find(".form_in_place", visible: true)

          @new_description = "new description"
          @edit_form.fill_in "short_description", with: @new_description

          @edit_form.find('input[type="submit"]').click
          wait_for_ajax

          visit project_path(@project)
        end

        scenario "Then a new notification has been created" do
          expect(@user.notifications.count).to eq @notification_count + 1
        end

        scenario "Then the notification increases the number of unread notifications on the top menu alert" do
          expect(find(".btn-bell__counter").text.to_i).to eq @alert_number + 1
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
        end
      end
    end
  end
end
