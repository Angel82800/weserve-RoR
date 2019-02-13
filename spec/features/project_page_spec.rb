require 'rails_helper'
feature "Project Page", js: true do
  before do
    @project_leader = FactoryGirl.create(:user, confirmed_at: Time.now)
    @usual_user = FactoryGirl.create(:user, confirmed_at: Time.now)
    @project = FactoryGirl.create(:project, user: @project_leader)
  end

  context "When you visit your project page as project leader" do
    before do
      login_as(@project_leader, :scope => :user, :run_callbacks => false)
      visit taskstab_project_path(@project, tab: 'plan')
    end

    scenario "Then you can see the project image" do
      expect(page).to have_xpath("//img[contains(@src, @project.picture.file.filename)]")
    end

    scenario "Then you can see the project manager's image" do
      expect(page.find(".project_author")).to have_xpath("//img[contains(@src, @project.user.picture.file.filename)]")
    end

    scenario "Then you can see the project title" do
      expect(page.find(".b-project-info__title")).to have_content @project.title
    end

    scenario "Then you can see the project activities" do
      expect(page).to have_selector(".project_activities")
    end

    scenario "Then you can see the project plan tab" do
      expect(page.find(".tabs-menu")).to have_selector("#tab-plan")
    end

    scenario "Then you can see the project tasks tab" do
      expect(page.find(".tabs-menu")).to have_content(I18n.t('projects.taskstab.tasks_tab_title'))
    end

    scenario "Then you can see the project revisions tab" do
      expect(page).to have_selector("#editSource")
    end

    scenario "Then you can see the project team tab" do
      expect(page.find(".tabs-menu")).to have_content(I18n.t('projects.taskstab.team_tab.title'))
    end

    scenario "Then you can see the project requests tab" do
      expect(page.find(".tabs-menu")).to have_content(I18n.t('projects.taskstab.requests_tab_title'))
    end
  end

  context "When you visit project without logging in" do
    before do
      visit taskstab_project_path(@project, tab: 'tasks')
      wait_for_ajax
      @boards_div = find('.boards')
    end

    scenario 'Then the board appeared' do
      expect(@boards_div).to have_content @project.boards.first.title
    end

    context 'and you clicked the flag' do
      before do
        find('div.s-header__lang-select').click
        @modal = find('div#changeLanguageModal', visible: true)
      end

      scenario "Then language selection modal appeared" do
        expect(@modal).to be_visible
      end

      context 'and you selected French' do
        before do
          find('.modal-change-language__name', :text => 'French').click
        end

        scenario "Then the page is translated to french" do
          expect(page).to have_content I18n.t('projects.taskstab.tasks_tab_title', locale: 'fr')
        end

        scenario "Then the board appeared" do
          expect(@boards_div).to have_content @project.boards.first.title
        end
      end
    end
  end
end
