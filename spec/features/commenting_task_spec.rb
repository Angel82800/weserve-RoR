require 'rails_helper'

shared_examples "existing comment after page reload" do
  before do
    visit project_path(@project)

    find("ul.m-tabs li a[data-tab='tasks']").trigger("click")
    wait_for_ajax

    funding_section = all("[data-task-id='#{@task.id}']").first

    funding_section.trigger("click")
    wait_for_ajax

    @comments = find(".l-comments__list")
  end

  scenario "Then the comment exists in the comments section" do
    @form.fill_in "task_comment_body", with: @comment
    page.find(".f-comment-post__send-btn").trigger("click")
    wait_for_ajax
    expect(@comments).to have_content(@comment, wait: false)
  end

  scenario "Then the attach exists in the comments section" do
    expect(@comments).to have_xpath("//img[contains(@src, @attach)]")
  end
end

feature "Create a Task", js: true do
  before do
    users = FactoryGirl.create_list(:user, 2, confirmed_at: Time.now)
    @user = users.first
    @regular_user = users.last

    @project = FactoryGirl.create(:project, user: @user)
    @task = FactoryGirl.create(:task, project: @project)
    @project_team = @project.create_team(name: "Team#{@project.id}")
    @team_membership = TeamMembership.create(team_member_id: @user.id, team_id: @project_team.id, role:1)
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

          @funding_section = all("[data-task-id='#{@task.id}']").first
        end

        context "When you click the task" do
          before do
            @funding_section.click

            @task_modal = find("#myModal")
          end

          scenario "Then the task modal appeared" do
            expect(@task_modal).to be_visible
          end

          scenario "Then the comments section exists in the modal" do
            expect(@task_modal).to have_selector(".l-comments")
          end

          context "When you put some text into comments" do
            before do
              @comment = "new comment"
              @comments_section = find(".l-comments")
              @form = find(".f-comment-post__form")

              @form.fill_in "task_comment_body", with: @comment
            end

            context "and send form without attaching a file" do
              before do
                page.find(".f-comment-post__send-btn").trigger("click")
              end

              scenario "Then the text appeared in the comments section" do
                expect(@comments_section).to have_content @comment
              end

              context "When you reload the page and reopen the task modal" do
                it_behaves_like "existing comment after page reload"
              end
            end

            context "and send form attaching a valid file" do
              before do
                @attach = "photo.png"
                @form.attach_file 'task_comment[attachment]', Rails.root + "spec/fixtures/#{@attach}"

                find(".f-comment-post__send-btn").trigger("click")
              end

              scenario "Then the text appeared in the comments section" do
                expect(@comments_section).to have_content @comment
              end

              scenario "Then the attached file appeared in the comments section" do
                expect(@comments_section).to have_xpath("//img[contains(@src, @attach)]")
              end

              context "When you reload the page and reopen the task modal" do
                it_behaves_like "existing comment after page reload"
              end
            end

            context "and send form attaching an invalid file" do
              before do
                @attach = "invalid_file.bin"
                @form.attach_file 'task_comment[attachment]', Rails.root + "spec/fixtures/#{@attach}"

                @form.click_button "Send"
              end

              scenario "Then the text is not appeared in the comments section" do
                expect(@comments_section).not_to have_content @comment
              end

              scenario "Then the attached file is not appeared in the comments section" do
                expect(@comments_section).to have_xpath("//img[contains(@src, @attach)]")
              end
            end
          end
        end
      end
    end
  end

  context "As a non team member" do
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

            @task_modal = page.find("#myModal")
          end

          scenario "Then the task modal appeared" do
            expect(@task_modal).to be_visible
          end

          scenario "Then the comments history exists in the modal" do
            expect(@task_modal).to have_selector(".l-comments")
          end

          scenario "Then the comments form exist in the modal" do
            expect(@task_modal).to have_selector(".f-comment-post__form")
          end
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

          scenario "Then the comments form does not exist in the modal" do
            expect(@task_modal).not_to have_selector(".f-comment-post__form")
          end
        end
      end
    end
  end
end
