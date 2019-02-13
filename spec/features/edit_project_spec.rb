require 'rails_helper'

feature 'Edit project text', js: true do
  context 'As project leader edit project' do
    before do
      @user = FactoryGirl.create(:user, confirmed_at: Time.now)
      @project = FactoryGirl.build(:project)
      login_as(@user, :scope => :user, :run_callbacks => false)
      visit root_path
    end

    scenario 'Redirected to Visual Editor when click Edit on Revisions tab',
             vcr: { cassette_name: 'mediawiki/history',
                    match_requests_on: [:path] } do
      click_pseudo_link 'Start a Project'
      @modal = find('div#startProjectModal', visible: true)
      expect(@modal).to be_visible
      @modal.fill_in 'project[title]', with: @project.title
      @modal.fill_in 'project[short_description]', with: @project.short_description
      @modal.fill_in 'project[country]', with: @project.country
      @modal.attach_file 'project[picture]', Rails.root + "spec/fixtures/photo.png"
      @modal.click_button 'Create Project'
      wait_for_ajax
      #puts page.body
      expect(page).to have_content @project.title
      expect(page).to have_selector("#editSource")
      find('#projectInviteModal .modal-default__close').trigger('click')
      wait_for_ajax
      find("ul.m-tabs li a[data-tab='plan']").trigger('click')
      wait_for_ajax
      click_pseudo_link 'Review contributions'
      wait_for_ajax
      expect(page).to have_selector('.revision-histories-body')
      expect(page).to have_selector('.revisions-compare-edit-link')
      find('.revisions-compare-edit-link').trigger('click')
      expect(page).to have_selector('body.mediawiki')
    end
  end
end
