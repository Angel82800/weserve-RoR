require 'rails_helper'

feature "My Profile", js: true do

  context "As logged in user" do
    before do
      @current_user = FactoryGirl.create(:user, confirmed_at: Time.now)
      @projects = FactoryGirl.create_list(:project, 2, user: @current_user)

      login_as(@current_user, :scope => :user, :run_callbacks => false)
    end

    context "When you visit the Home page and the click your name link" do
      before do
        visit '/'
        find("a.pr-user").trigger("click")

        @dropdown = find("ul.dropdown-menu")
      end

      scenario "Then you can see the 'My Profile' link in the top right dropdown menu" do
        expect(@dropdown).to be_visible
      end

      context "When you click the 'My Profile' link" do
        before do
          @dropdown.click_link "My Profile"
          @profile_header = page.find(".profile-hero")
          @profile_bio = find(".bio-wrapper")
        end

        scenario "Then you are redirected to the profile page" do
          expect(page).to have_current_path(user_path(@current_user))
        end

        scenario "Then you can see your profile info in the header part" do
          expect(@profile_header).to have_content @current_user.display_name
        end

        scenario "Then you can see the list of projects" do
          projects_part = find(".profile-projects")

          @projects.each do |project|
            expect(projects_part).to have_content project.title
          end
        end


        context "When you click edit profile link" do
          before do
            find('a.profile-hero__edit-button').trigger("click")
            @edit_form = find("#editProfileModal")
          end

          scenario "Then your edit form is availble to be changed" do
            expect(@edit_form).to be_visible
          end

          context "When you change your first_name and click 'Save' button" do
            before do
              @first_name = "FirstNameTest"
              @user_old = User.last
              @edit_form.find('._first-name').set(@first_name)
              @edit_form.find('button[type="submit"]').click
              @user = User.last
            end

            scenario "Then your first name has been changed" do
              expect(@profile_header).to have_text @first_name
            end

            scenario "Then users are different after save" do
              expect(@user).to_not be(@user_old)
            end

            scenario "Then users different only in one attribute" do
              @user.first_name = @user_old.first_name
              expect(@user).to eq(@user_old)
            end
          end
          context "When you change your language and click 'Save' button" do
            before do
              @user_old = User.last
              @edit_form.find('select').select('French')
              @edit_form.find('button[type="submit"]').click
              wait_for_ajax
              @user = User.last
            end
            scenario "it saves with french language" do
              expect(@user.preferred_language).to eq("fr")
            end
          end
        end

      end
    end
  end
end
