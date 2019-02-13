require 'rails_helper'

feature "Edit a Task", js: true do
  before do
    users = FactoryGirl.create_list(:user, 2, confirmed_at: Time.now)
    @user = users.first
    @regular_user = users.last
    @admin = FactoryGirl.create(:user, confirmed_at: Time.now, admin: true)
    @project = FactoryGirl.create(:project, user: @user)
    @task = FactoryGirl.create(:task, project: @project)
    allow_any_instance_of(Payments::StripeSources).to receive(:call).and_return([{id: @user.id, last4: 4242}])
  end

  context "As project leader" do
    before do
      login_as(@user, :scope => :user, :run_callbacks => false)
    end

    context "When you navigate the project page" do
      before do
        visit project_path(@project)
      end

      context "When you click 'Task' button" do
        before do
          find("ul.m-tabs li a[data-tab='tasks']").trigger("click")
          wait_for_ajax

          @pending_section = all("[data-task-id='#{@task.id}']").first
          @task_area = find(".tabs-wrapper__tasks")
        end

        scenario "Then the sortable was applied" do
          expect(@task_area).to have_selector(".ui-sortable")
        end

        context "When you click the task" do
          before do
            @pending_section.click

            @task_modal = find("#myModal")
          end

          scenario "Then the task modal appeared" do
            expect(@task_modal).to be_visible
          end

          context "When you click the title" do
            before do
              find("#task-title").trigger("click")

              @form = find("#task-update-title-form")
            end

            scenario "Then the title is avialble to be edited" do
              expect(@form).to be_visible
            end

            context "When you fill the title and click 'Save' button" do
              before do
                @title = "new title"
                @form.fill_in "task[title]", with: @title

                @form.click_button "Save"
                wait_for_ajax
              end

              scenario "Then the title has been changed" do
                expect(@task_modal).to have_content @title
              end

              context "When you reload the page and reopen the task modal" do
                before do
                  visit project_path(@project)

                  find("ul.m-tabs li a[data-tab='tasks']").trigger("click")
                  wait_for_ajax

                  pending_section = all("[data-task-id='#{@task.id}']").first

                  pending_section.click

                  @task_modal = find("#myModal")
                end

                scenario "Then the changed title exists in the modal" do
                  expect(@task_modal).to have_content @title
                end
              end
            end
          end

          context "When you click the condition" do
            before do
              find("#task-condition").trigger("click")

              @form = find("#task-update-condition-form")
            end

            scenario "Then the condition is avialble to be edited" do
              expect(@form).to be_visible
            end

            context "When you fill the condition and click 'Save' button" do
              before do
                @condition = "new condition"
                @form.fill_in "task[condition_of_execution]", with: @condition

                @form.click_button "Save"
                wait_for_ajax
              end

              scenario "Then the condition has been changed" do
                expect(@task_modal).to have_content @condition
              end

              context "When you reload the page and reopen the task modal" do
                before do
                  visit project_path(@project)

                  find("ul.m-tabs li a[data-tab='tasks']").trigger("click")
                  wait_for_ajax

                  pending_section = all("[data-task-id='#{@task.id}']").first

                  pending_section.click

                  @task_modal = find("#myModal")
                end

                scenario "Then the changed condition exists in the modal" do
                  expect(@task_modal).to have_content @condition
                end
              end
            end
          end

          context "When you click the proof" do
            before do
              find("#task-proof").trigger("click")

              @form = find("#task-update-proof-form")
            end

            scenario "Then the proof is avialble to be edited" do
              expect(@form).to be_visible
            end

            context "When you fill the proof and click 'Save' button" do
              before do
                @proof = "new proof"
                @form.fill_in "task[proof_of_execution]", with: @proof

                @form.click_button "Save"
                wait_for_ajax
              end

              scenario "Then the title has been changed" do
                expect(@task_modal).to have_content @proof
              end

              context "When you reload the page and reopen the task modal" do
                before do
                  visit project_path(@project)

                  find("ul.m-tabs li a[data-tab='tasks']").trigger("click")
                  wait_for_ajax

                  pending_section = all("[data-task-id='#{@task.id}']").first

                  pending_section.click

                  @task_modal = find("#myModal")
                end

                scenario "Then the changed proof exists in the modal" do
                  expect(@task_modal).to have_content @proof
                end
              end
            end
          end
        end
      end
    end
  end

  context "As admin" do
    before do
      login_as(@admin, :scope => :user, :run_callbacks => false)
    end

    context "When you navigate the project page" do
      before do
        visit project_path(@project)
      end

      context "When you click 'Task' button" do
        before do
          find("ul.m-tabs li a[data-tab='tasks']").trigger("click")
          wait_for_ajax

          @pending_section = all("[data-task-id='#{@task.id}']").first
          @task_area = find(".tabs-wrapper__tasks")
        end

        scenario "Then the sortable was applied" do
          expect(@task_area).to have_selector(".ui-sortable")
        end

        context "When you click the task" do
          before do
            @pending_section.click

            @task_modal = find("#myModal")
          end

          scenario "Then the task modal appeared" do
            expect(@task_modal).to be_visible
          end

          context "When you click the title" do
            before do
              find("#task-title").trigger("click")

              @form = find("#task-update-title-form")
            end

            scenario "Then the title is avialble to be edited" do
              expect(@form).to be_visible
            end

            context "When you fill the title and click 'Save' button" do
              before do
                @title = "new title"
                @form.fill_in "task[title]", with: @title

                @form.click_button "Save"
                wait_for_ajax
              end

              scenario "Then the title has been changed" do
                expect(@task_modal).to have_content @title
              end

              context "When you reload the page and reopen the task modal" do
                before do
                  visit project_path(@project)

                  find("ul.m-tabs li a[data-tab='tasks']").trigger("click")
                  wait_for_ajax

                  pending_section = all("[data-task-id='#{@task.id}']").first

                  pending_section.click

                  @task_modal = find("#myModal")
                end

                scenario "Then the changed title exists in the modal" do
                  expect(@task_modal).to have_content @title
                end
              end
            end
          end

          context "When you click the condition" do
            before do
              find("#task-condition").trigger("click")

              @form = find("#task-update-condition-form")
            end

            scenario "Then the condition is avialble to be edited" do
              expect(@form).to be_visible
            end

            context "When you fill the condition and click 'Save' button" do
              before do
                @condition = "new condition"
                @form.fill_in "task[condition_of_execution]", with: @condition

                @form.click_button "Save"
                wait_for_ajax
              end

              scenario "Then the condition has been changed" do
                expect(@task_modal).to have_content @condition
              end

              context "When you reload the page and reopen the task modal" do
                before do
                  visit project_path(@project)

                  find("ul.m-tabs li a[data-tab='tasks']").trigger("click")
                  wait_for_ajax

                  pending_section = all("[data-task-id='#{@task.id}']").first

                  pending_section.click

                  @task_modal = find("#myModal")
                end

                scenario "Then the changed condition exists in the modal" do
                  expect(@task_modal).to have_content @condition
                end
              end
            end
          end

          context "When you click the proof" do
            before do
              find("#task-proof").trigger("click")

              @form = find("#task-update-proof-form")
            end

            scenario "Then the proof is avialble to be edited" do
              expect(@form).to be_visible
            end

            context "When you fill the proof and click 'Save' button" do
              before do
                @proof = "new proof"
                @form.fill_in "task[proof_of_execution]", with: @proof

                @form.click_button "Save"
                wait_for_ajax
              end

              scenario "Then the title has been changed" do
                expect(@task_modal).to have_content @proof
              end

              context "When you reload the page and reopen the task modal" do
                before do
                  visit project_path(@project)

                  find("ul.m-tabs li a[data-tab='tasks']").trigger("click")
                  wait_for_ajax

                  pending_section = all("[data-task-id='#{@task.id}']").first

                  pending_section.click

                  @task_modal = find("#myModal")
                end

                scenario "Then the changed proof exists in the modal" do
                  expect(@task_modal).to have_content @proof
                end
              end
            end
          end
        end
      end
    end
  end

  context "As regular user who is not author of the task" do
    before do
      login_as(@regular_user, :scope => :user, :run_callbacks => false)
    end

    context "When you navigate the project page" do
      before do
        visit project_path(@project)
      end

      context "When you click 'Task' button" do
        before do
          find("ul.m-tabs li a[data-tab='tasks']").trigger("click")
          wait_for_ajax

          @pending_section = all("[data-task-id='#{@task.id}']").first
        end

        context "When you click the task" do
          before do
            @pending_section.click

            @task_modal = find("#myModal")
          end

          scenario "Then the task modal appeared" do
            expect(@task_modal).to be_visible
          end

          # scenario "Then the task detail is not editable" do
          #   expect(@task_modal).not_to have_selector(".js-toggleForm")
          # end
        end
      end
    end
  end

  context "As anonymous" do
    context "When you navigate the project page" do
      before do
        visit project_path(@project)
      end

      context "When you click 'Task' button" do
        before do
          find("ul.m-tabs li a[data-tab='tasks']").trigger("click")
          wait_for_ajax

          @pending_section = all("[data-task-id='#{@task.id}']").first
        end

        context "When you click the task" do
          before do
            @pending_section.click

            @task_modal = find("#myModal")
          end

          scenario "Then the task modal appeared" do
            expect(@task_modal).to be_visible
          end

          # scenario "Then the task detail is not editable" do
          #   expect(@task_modal).not_to have_selector(".js-toggleForm")
          # end
        end
      end
    end
  end
end
