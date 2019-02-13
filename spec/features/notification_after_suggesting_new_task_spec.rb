require 'rails_helper'

xfeature "Notification After Suggesting a New Task", js: true do
  before do
    users = FactoryGirl.create_list(:user, 2, confirmed_at: Time.now)
    @user = users.first
    @regular_user = users.last
    @project = FactoryGirl.create(:project, user: @user)
  end

  context "As Regular User" do
    before do
      login_as(@regular_user, :scope => :user, :run_callbacks => false)
    end

    context "When you visit the project page" do
      before do
        visit project_path(@project)
        @task_area = find(".tabs-wrapper__tasks")
      end

      context "When you click 'Task' button" do
        before do
          find("ul.m-tabs li a[data-tab='tasks']").trigger("click")
          wait_for_ajax
        end

        context "When you click 'Suggest a task' link" do
          before do
            @task_area.find("#suggest-new-task").trigger("click")
            wait_for_ajax

            @modal = find("#newTaskModal")
          end

          context "When you fill all the fields and click 'Create task' button" do
            before do
              @task = FactoryGirl.build(:task, project: @project)

              @modal.fill_in 'task[title]', with: @task.title
              @modal.fill_in 'task[budget]', with: @task.budget
              @modal.fill_in 'task[condition_of_execution]', with: @task.condition_of_execution
              @modal.fill_in 'task[proof_of_execution]', with: @task.proof_of_execution
              @modal.fill_in 'task[deadline]', with: @task.deadline

              @modal.click_button I18n.t('commons.create_task')
            end

            scenario "Then a new notification has been created" do
              expect(@user.notifications.count).not_to be_zero
            end

            scenario "Then the notification alert is not created on the top menu" do
              expect(page).not_to have_selector(".btn-bell__counter")
            end

            context "When you navigate 'Notifications' page" do
              before do
                find(".notify-dropdown").click
                wait_for_ajax

                @dropdown = find(".b-dropdown", visible: true)

                @dropdown.find(".b-dropdown__link").click_link I18n.t('notifications.see_all_message')
              end

              scenario "Then you can not see the notification" do
                expect(page).not_to have_content "#{@regular_user.display_name} suggested a task #{@task.title}"
              end

              scenario "Then the number of unread notifications has been disappeared on the alert" do
                expect(page).not_to have_selector(".btn-bell__counter")
              end
            end
          end
        end
      end
    end
  end

  context "As Project Leader" do
    before do
      login_as(@user, :scope => :user, :run_callbacks => false)
    end

    context "When you visit the project page" do
      before do
        visit project_path(@project)
        @task_area = find(".tabs-wrapper__tasks")
      end

      context "When you click 'Task' button" do
        before do
          find("ul.m-tabs li a[data-tab='tasks']").trigger("click")
          wait_for_ajax
        end

        context "When you click 'Suggest a task' link" do
          before do
            @task_area.find("#suggest-new-task").trigger("click")
            wait_for_ajax

            @modal = find("#newTaskModal")
          end

          context "When you fill all the fields and click 'Create task' button" do
            before do
              @task = FactoryGirl.build(:task, project: @project)

              @modal.fill_in 'task[title]', with: @task.title
              @modal.fill_in 'task[budget]', with: @task.budget
              @modal.fill_in 'task[condition_of_execution]', with: @task.condition_of_execution
              @modal.fill_in 'task[proof_of_execution]', with: @task.proof_of_execution
              @modal.fill_in 'task[deadline]', with: @task.deadline

              @modal.click_button I18n.t('commons.create_task')
            end

            scenario "Then a new notification has been created" do
              expect(@user.notifications.count).not_to be_zero
            end

            scenario "Then the notification creates an alert on the top menu" do
              expect(page).to have_selector(".btn-bell__counter")
            end

            scenario "Then the notification alert indicates the number of unread notifications" do
              expect(find(".btn-bell__counter").text).to eq Notification.unread.count.to_s
            end

            context "When you navigate 'Notifications' page" do
              before do
                find(".notify-dropdown").click
                wait_for_ajax

                @dropdown = find(".b-dropdown", visible: true)

                @dropdown.find(".b-dropdown__link").click_link I18n.t('notifications.see_all_message')
              end

              scenario "Then you can see the notification" do
                expect(page).to have_content "#{@user.display_name} suggested a task #{@task.title}"
              end

              scenario "Then the number of unread notifications has been disappeared on the alert" do
                expect(page).not_to have_selector(".btn-bell__counter")
              end
            end
          end
        end
      end
    end
  end
end
