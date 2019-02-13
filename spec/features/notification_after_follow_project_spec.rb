require 'rails_helper'

xfeature 'Notification After Follow the Project', js: true do
  let(:user)          { create(:user, :confirmed_user) }
  let(:project)       { create(:project) }

  before do
    login_as(user, scope: :user, run_callbacks: false)
    visit project_path(project)
  end

  context 'notifications on top menu' do
    scenario 'notifies user on follow a project' do
      find('.btn-root.follow-unfollow').click
      wait_for_ajax

      expect(page).to have_content(I18n.t('projects.follow_project.notification'))
    end
  end
end
