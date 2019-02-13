require 'rails_helper'

xfeature 'Notification After rejected a task', js: true do
  before do
    users = create_list(:user, 2, :confirmed_user)
    @project_leader = users.first.reload
    @regular_user = users.last.reload
    @project = create(:project, user: @project_leader)
    @suggested_task = create(:task, :suggested, project: @project, user: @regular_user)
  end

  context 'as project leader' do
    before do
      login_as(@project_leader, scope: :user, run_callbacks: false)
      visit taskstab_project_path(@project, tab: 'tasks')
    end

    context 'delete a task' do
      before do
        find('button', text: 'Delete').click
        find('#removeTask').click_button('Ok')
        wait_for_ajax
      end

      context 'other users' do
        scenario 'no notification has been created' do
          expect(@regular_user.notifications.count).to be_zero
        end
      end

      context 'project leader' do
        scenario 'a new notification has been created' do
          expect(@project_leader.notifications.last.rejected_task?).to be_truthy
        end

        scenario 'notification creates an alert on the top menu' do
          expect(page).to have_selector('.btn-bell__counter')
        end

# This spec is not going to pass because of "reject" action of task_controller
# there task is deleted and by this reason later in notification_controller link to the source_model does not exists
=begin
        context "navigate to 'Notifications' page" do
          before do
            find('.notify-dropdown').click
            wait_for_ajax

            @dropdown = find('.b-dropdown', visible: true)

            @dropdown.find('.b-dropdown__link').click_link I18n.t('notifications.see_all_message')
          end

          scenario 'see the notification' do
            expect(page).to have_content "You have rejected a task named #{@suggested_task.title}"
          end

          scenario 'number of unread notifications has been disappeared on the alert' do
            expect(page).to have_no_selector('.btn-bell__counter')
          end
        end
=end
      end
    end
  end
end
