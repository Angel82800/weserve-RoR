require 'rails_helper'

feature "Project Page Subprojects Tab", js: true do
  let(:leader_user) { create(:user, :confirmed_user) }
  let(:regular_user) { create(:user, :confirmed_user) }
  let(:parent_project) { create(:project, user: leader_user, children: [child_project]) }
  let(:child_project) { create(:project, user: leader_user, title: 'Child project') }

  context "As project leader" do
    before { login_as(leader_user, :scope => :user, :run_callbacks => false) }

    context "When you visit the project page" do
      before { visit taskstab_project_path(parent_project) }

      scenario "Then you can see 'Subprojects' tab" do
        expect(page).to have_css("#subprojects-tab-link")
      end

      context "When you click 'Subprojects' tab" do
        before do
          click_link('subprojects-tab-link')
          wait_for_ajax
        end

        scenario "Then you can see button to create Subprojects" do
          expect(page).to have_css("#create-sub-project")
        end

        scenario "Then you can see subproject title" do
          within '.subprojects-wrapper' do
            expect(page).to have_content 'Child project'
          end
        end

        scenario "Then you can see remove subproject button" do
          within '.subprojects-wrapper' do
            expect(page).to have_css(".b-project-card__remove-subproject-link")
          end
        end

        context "When you create a new subproject" do
          before do
            click_link I18n.t('projects.tabcontent.plan.create_sub_project')
            wait_for_ajax
            modal = find('div#startProjectModal', visible: true)
            modal.fill_in 'project[title]', with: 'This is a New project'
            modal.fill_in 'project[short_description]', with: 'New description'
            modal.fill_in 'project[country]', with: 'Chile'
            modal.click_button 'Create Project'
            wait_for_ajax
            find('div#projectInviteModal button.modal-default__close',
                 visible: true).click
            visit taskstab_project_path(parent_project)
            click_link('subprojects-tab-link')
            wait_for_ajax
          end

          scenario "Then you can see the new subproject listed" do
            within '.subprojects-wrapper' do
              expect(page).to have_content 'This is a New project'
            end
          end
        end

      #   context "When you click on remove project link" do
      #     scenario "Then the subproject is removed" do
      #       within '.subprojects-wrapper' do
      #         find_link('Remove as parent project').click
      #         wait_for_ajax
      #         expect(page).not_to have_content 'Child project'
      #       end
      #     end
      #   end
      end
    end

  end

  context "As regular user" do
    before do
      login_as(regular_user, :scope => :user, :run_callbacks => false)
    end

    context "When you visit the project page" do
      before { visit taskstab_project_path(parent_project) }

      scenario "Then you can see 'Subprojects' tab" do
        expect(page).to have_css("#subprojects-tab-link")
      end

      context "When you click 'Subprojects' tab" do
        before do
          click_link('subprojects-tab-link')
          wait_for_ajax
        end

        scenario "Then you can see button to create Subprojects" do
          expect(page).to have_css("#create-sub-project")
        end

        scenario "Then you can see subproject title" do
          within '.subprojects-wrapper' do
            expect(page).to have_content 'Child project'
          end
        end

        scenario "Then you can not remove subprojects" do
          within '.subprojects-wrapper' do
            expect(page).not_to have_css("a[title='Remove as parent project']")
          end
        end
      end
    end
  end

  context "As anonymous user" do
    context "When you visit the project page" do
      before { visit taskstab_project_path(parent_project) }

      scenario "Then you can see 'Subprojects' tab" do
        expect(page).to have_css("#subprojects-tab-link")
      end

      context "When you click 'Subprojects' tab" do
        before do
          click_link('subprojects-tab-link')
          wait_for_ajax
        end

        scenario "Then you can't see the button to create Subprojects" do
          expect(page).not_to have_css("#create-sub-project")
        end

        scenario "Then you can see subproject title" do
          within '.subprojects-wrapper' do
            expect(page).to have_content 'Child project'
          end
        end

        scenario "Then you can not remove subprojects" do
          within '.subprojects-wrapper' do
            expect(page).not_to have_css("a[title='Remove as parent project']")
          end
        end
      end
    end
  end
end
