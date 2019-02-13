require 'rails_helper'

feature "My Projects Archive", js: true do

  context "As logged in user" do
    before do
      @current_user = FactoryGirl.create(:user, confirmed_at: Time.now)
      @project = FactoryGirl.create(:project, user: @current_user)

      login_as(@current_user, :scope => :user, :run_callbacks => false)
    end

    context "When you visit My Projects page" do
      before do
        visit my_projects_path
        @projects_table = find(".myprojets-table")
      end

      scenario "Then you can see Delete icon in each project row" do
        expect(@projects_table.find("table.table")).to have_selector("td.delete")
      end

      context "When you click Delete icon in a project" do
        before do
          @projects_table.find(:xpath, "//button[@onclick='removeProject(#{@project.id})']").trigger('click')
          @modal = find("#modalRemoveProject")
        end

        scenario "Then the confirmation popup appeared" do
          expect(@modal).to be_visible
        end

        scenario "The link of ok button match with the link of project" do
          expect(@modal).to have_link(nil, href: project_path(@project.id))
        end

        context "When you confirm" do
          before do
            @modal.find(".btn-root._agree").trigger("click")
            wait_for_ajax
            sleep 1
          end

          scenario "Then the project has been archived" do
            expect(@projects_table).not_to have_content @project.title
          end

          scenario "Then the project has not been removed completely" do
            expect(Project.only_deleted.include? @project).to be true
          end

          context "When you visit Archived Projects page As admin user" do
            before do
              @admin_user = FactoryGirl.create(:user, confirmed_at: Time.now)
              @admin_user.admin!

              login_as(@admin_user, :scope => :user, :run_callbacks => false)

              visit archived_projects_path
            end

            scenario "Then you can see the archived project" do
              expect(page).to have_content @project.title
            end
          end
        end
      end
    end
  end
end
