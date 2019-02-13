require 'rails_helper'

feature "Project Page Revisions Tab", js: true do
  before do
    users = FactoryGirl.create_list(:user, 2, confirmed_at: Time.now)
    @user = users.first
    @regular_user = users.last
    @project = FactoryGirl.create(:project, user: @user)
  end

  context "As project leader" do
    before do
      login_as(@user, :scope => :user, :run_callbacks => false)
    end

    context "When you visit the project page" do
      before do
        visit taskstab_project_path(@project, tab: 'plan')
        @plan_area = find(".tabs-wrapper__plan")
        @button_tabs = find(".project-btn-group")
        @revision_button = find("#editSource")

        @revisions = [
          {
            "id" => 1,
            "timestamp" => Time.now.to_s,
            "author" => @user.username,
            "status" => "approved",
            "comment" => "comment",
            "is_blocked" => true
          }
        ]
        allow_any_instance_of(Project).to receive(:get_history).and_return(@revisions)
      end

      scenario "Then you can see 'Revisions' button" do
        expect(@plan_area).to have_selector("#editSource")
      end

      # disabled https://weserveio.atlassian.net/browse/WS-1770
      xcontext "When you click 'Revisions' button" do
        before do
          @revision_button.click
          wait_for_ajax

          @revision_wrapper = find(".revision-wrapper")
        end

        scenario "Then you can see revisions in the table" do
          expect(@revision_wrapper.find("table.table")).to have_xpath "//tr[contains(@data-revision-username, #{@revisions.first['author']})]"
        end

        scenario "Then you can see 'Compare revisions' button" do
          expect(@revision_wrapper).to have_selector("a.revisions-compare-button")
        end

        scenario "Then you can see 'Verification' switch" do
          expect(@revision_wrapper).to have_selector "label.switch"
        end

        context "When you click on 'Verification' switch" do
          before do
            @revision_wrapper.find(".approval-switch input").trigger("click")

            @warning_modal = find("#modalVerification", visible: true)
          end

          scenario "Then the warning modal appeared" do
            expect(@warning_modal).to be_visible
          end

          context "When you click 'Ok' on the warning modal" do
            before do
              @warning_modal.click_button I18n.t('commons.ok')
            end

            scenario "Then the switch has been active" do
              expect(@revision_wrapper.find(".approval-switch input")).to be_checked
            end
          end
        end

        context "When you click 'Back' button" do
          before do
            @revision_wrapper.click_link I18n.t('devise.shared.links.back')
          end

          scenario "Then you are back to 'Plan' tab"
        end
      end
    end
  end

  context "As regular user" do
    before do
      login_as(@regular_user, :scope => :user, :run_callbacks => false)
    end

    context "When you visit the project page" do
      before do
        visit project_path(@project)
        @plan_area = find(".tabs-wrapper__plan")
      end

      scenario "Then you can't see 'Revisions' button" do
        expect(@plan_area).not_to have_link "Revisions"
      end
    end
  end

  context "As anonymous user" do
    context "When you visit the project page" do
      before do
        visit project_path(@project)
        @plan_area = find(".tabs-wrapper__plan")
      end

      scenario "Then you can't see 'Revisions' button" do
        expect(@plan_area).not_to have_link "Revisions"
      end
    end
  end
end
