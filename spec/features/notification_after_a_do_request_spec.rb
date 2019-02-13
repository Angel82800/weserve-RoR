require 'rails_helper'

xfeature "Notification After submitting a do request", js: true do
  before do
    users = FactoryGirl.create_list(:user, 2, confirmed_at: Time.now)
    @user = users.first
    @regular_user = users.last
    @project = FactoryGirl.create(:project, user: @user)
    @task = FactoryGirl.create(:task, project: @project, user: @user)
  end

  context "As Regular User" do
    before do
      @regular_user.reload
      login_as(@regular_user, :scope => :user)
    end

    context "When you visit the task page" do
      before do
        visit taskstab_project_path(@project, tab: 'tasks', taskId: @task.id)
      end

      context "When you click 'Do' button" do
        before do
          @modal = find(".modal-task__content", visible: true)
          @modal.click_button("DO")
        end

        context "When you fill out do request fields and click submit button" do
          before do
            @cover_letter = "test"

            expect(page).to have_selector("#do-request-button", visible: true)
            fill_in 'do_request[application]', with: @cover_letter
            find("#do-request-button").click
          end

          it "hides do request modal form" do
            expect(page).to have_selector("#do-request-button", visible: false)
          end

          context "As project leader" do
            before do
              @user.reload
              login_as(@user, :scope => :user)
            end

            context "When you visit notifications page" do
              before do
                visit notifications_path
              end

              it "shows do-request notification" do
                expect(page).to have_content(
                  "#{@regular_user.display_name} requested to do this task #{@task.title}. Their cover letter is: #{@cover_letter}"
                )
              end
            end
          end
        end
      end
    end
  end
end
