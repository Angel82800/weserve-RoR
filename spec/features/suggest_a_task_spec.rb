require 'rails_helper'

xfeature "Suggest a Task", js: true do
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
        @task_area_selector = "#Tasks"
        @task_area = find(@task_area_selector)
      end

      scenario "Then you can see 'Task' button" do
        expect(find("ul.m-tabs")).to have_content  I18n.t('projects.taskstab.tasks_tab_title')
      end

      context "When you click 'Task' button" do
        before do
          find("ul.m-tabs li a[data-tab='tasks']").trigger("click")
        end

        scenario "Then the 'Tasks' screen appeared" do
          expect(page).to have_selector(@task_area_selector, visible: true)
        end

        scenario "Then the 'Suggest a task' link is the area" do
          expect(@task_area).to have_selector("#suggest-new-task")
        end

        context "When you click 'Suggest a task' link" do
          before do
            @task_area.find("#suggest-new-task").trigger("click")

            @modal_selector = "#newTaskModal"
            @modal = find(@modal_selector)
          end

          scenario "Then a modal appeared" do
            expect(page).to have_selector(@modal_selector, visible: true)
          end

          context "When you fill all the fields and click 'Create task' button" do
            before do
              @task = FactoryGirl.build(:task, project: @project)

              @modal.fill_in 'task[title]', with: @task.title
              @modal.fill_in 'task[budget]', with: @task.budget
              @modal.fill_in 'task[condition_of_execution]', with: @task.condition_of_execution
              @modal.fill_in 'task[proof_of_execution]', with: @task.proof_of_execution
              @modal.fill_in 'task[deadline]', with: @task.deadline

              @modal.find_button("Create Task").trigger("click")
            end

            scenario "Then new task has been created" do
              expect(page).not_to have_content(I18n.t('tasks.create.alert_message'))
              expect(page).to have_content(I18n.t('tasks.create.notice_message'))
            end

            context "When you navigate the project page" do
              before do
                visit project_path(@project)
              end

              context "When you click 'Task' button" do
                before do
                  find("ul.m-tabs li a[data-tab='tasks']").trigger("click")

                  @pending_section = find(".trello-column", match: :first)
                end

                scenario "Then the task has been appeared in the 'Pending approval' section" do
                  expect(@pending_section.find(".card-title")).to have_content @task.title
                end

                context "When you click the task" do
                  before do
                    @pending_section.find(".card-wrapper", match: :first).trigger("click")

                    @task_modal_selector = "#myModal"
                    @task_modal = find(@task_modal_selector)
                  end

                  scenario "Then the task modal appeared" do
                    expect(page).to have_selector(@task_modal_selector, visible: true)
                  end

                  scenario "Then all the information of the task is present in the modal" do
                    expect(@task_modal).to have_content @task.title
                    expect(@task_modal).to have_content @task.condition_of_execution
                    expect(@task_modal).to have_content @task.proof_of_execution
                  end

                  scenario "Then 'Delete task' button exists in the modal" do
                    expect(@task_modal).to have_selector("button.delete-task")
                  end

                  scenario "Then 'Approve' button does not exist in the modal" do
                    expect(@task_modal).not_to have_selector("#approveTaskPopover")
                  end

                  scenario "Then 'Activity' section exists in the modal" do
                    expect(@task_modal).to have_selector("#task-activity")
                  end

                  scenario "Then 'Activity' section contains the activity of the current user" do
                    expect(find("#task-activity")).to have_content "#{I18n.t('projects.task_activities.task_proposed_by')} #{@regular_user.display_name}"
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  context "As project leader" do
    before do
      login_as(@user, :scope => :user, :run_callbacks => false)
    end

    context "When you visit the project page" do
      before do
        visit project_path(@project)
        @task_area_selector = "#Tasks"
        @task_area = find(@task_area_selector)
      end

      scenario "Then you can see 'Task' button" do
        expect(find("ul.m-tabs")).to have_content I18n.t('projects.taskstab.tasks_tab_title')
      end

      context "When you click 'Task' button" do
        before do
          find("ul.m-tabs li a[data-tab='tasks']").trigger("click")
        end

        scenario "Then the 'Tasks' screen appeared" do
          expect(page).to have_selector(@task_area_selector, visible: true)
        end

        scenario "Then the 'Suggest a task' link should not be in the area" do
          expect(@task_area).not_to have_selector("#suggest-new-task")
        end
      end
    end
  end
end
