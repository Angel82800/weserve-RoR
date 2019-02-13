require 'rails_helper'

feature 'Request Changes', js: true do
  let!(:users) { create_list(:user, 2, :confirmed_user) }

  let(:project) { create(:project, user: users[0]) }
  let!(:task) { create(:task, :reviewing, project: project, user: users[0]) }

  let(:reviewing_section) { all("[data-task-id='#{task.id}']").first}
  let(:task_modal) { find("#myModal") }

  before(:each) do
    login_as(user, scope: :user, run_callbacks: false)
    visit project_path(project)

    find("ul.m-tabs li a[data-tab='tasks']").click
    wait_for_ajax

    reviewing_section.click
  end

  context 'When user is project leader' do
    let(:user) { users[0] }

    it { expect(task_modal).to have_button(I18n.t('projects.task_state_transition_dropdown.reviewing'))}

    context 'When dropdown opening' do

      before { click_on("In Review") }

      it { expect(task_modal).to have_content(I18n.t('projects.task_state_transition_dropdown.request_changes'))}
    end
  end

  # context 'When user is not project leader'  do
  #   let(:user) { users[1] }

    # it { expect(task_modal).to_not have_button(I18n.t('projects.task_state_transition_dropdown.mark_as_completed')}
  # end
end
