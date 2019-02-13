require 'rails_helper'

xfeature 'Notifications', js: true do
  let(:user)          { create(:user, :confirmed_user) }
  let(:another_user)  { create(:user, :confirmed_user) }
  let(:project)       { create(:project, user: user) }

  context 'load older notifications' do
    context 'notifications index page' do
      before do
        create_list(:task, 2, :suggested, user: another_user, project: project)

        login_as(user, scope: :user, run_callbacks: false)
        NotificationsController::PER_LOAD_COUNT = 2
        visit notifications_path
      end

      scenario 'loads the notification of id 111' do
        expect(page).not_to have_content(I18n.t('projects.create_project.notification '))

        find('.load-older-notifications-link a').click
        wait_for_ajax

        expect(page).to have_content(I18n.t('projects.create_project.notification '))
      end
    end

  end
  
  context 'notifications on top menu' do
    before do
      login_as(user, scope: :user, run_callbacks: false)
      visit project_path(project)
    end

    scenario 'notifies only notifications belong to loggin user' do
      expect(find(".notify-dropdown .b-dropdown__count .count").text.to_i).to eq 1
    end
  end
end
