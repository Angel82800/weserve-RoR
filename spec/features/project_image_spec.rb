require 'rails_helper'

feature "Project image", js: true do
  let(:old_photo) { "photo.png" }
  let(:new_photo) { "photo2.jpg" }

  context "As logged in user" do
    before do
      @user = FactoryGirl.create(:user, confirmed_at: Time.now)
      login_as(@user, :scope => :user, :run_callbacks => false)
      visit root_path
    end

    context "When you create a new project" do
      before do
        click_pseudo_link I18n.t('commons.start_a_project')

        modal = find('div#startProjectModal', visible: true)
        @project = FactoryGirl.build(:project)

        modal.fill_in 'project[title]', with: @project.title
        modal.fill_in 'project[short_description]', with: @project.short_description
        modal.fill_in 'project[country]', with: @project.country
        modal.attach_file 'project[picture]', Rails.root + "spec/fixtures/#{old_photo}"

        modal.click_button 'Create Project'

        wait_for_ajax

        @invite_modal = find('div#projectInviteModal', visible: true)
      end

      scenario "Then 'Share/Invite People to Participate' popup appeared" do        
        expect(@invite_modal).to be_visible
      end

      scenario "Then you see the project image" do
        expect(page).to have_xpath("//img[contains(@src, old_photo)]")
      end

      scenario "Then you see the 'Edit Project Image' button" do
        expect(page).to have_selector("a.btn-edit.btn-edit-image")
      end

      context "When you close the 'Share/Invite People to Participate' popup" do
        before do
          @invite_modal.find("button.modal-default__close").click
        end

        context "When you click the 'Edit Project Image' button" do
          before do
            page.find('a.btn-edit.btn-edit-image').trigger("click") 
            wait_for_ajax
            @edit_image_modal = page.find('div#project-img-edit', visible: true)
          end

          scenario "Then you can see 'Edit Project Image' popup" do
            expect(@edit_image_modal).to be_visible
          end

          scenario "Then you can change the project image" do
            expect(@edit_image_modal).to have_selector("input#project_picture")
          end

          context "When you upload new image" do
            before do
              @edit_image_modal.attach_file 'project[picture]', Rails.root + "spec/fixtures/#{new_photo}"
              @edit_image_modal.click_button I18n.t('commons.save_changes')
              wait_for_ajax
            end

            scenario "Then the project image has been changed" do
              expect(page).to have_xpath("//img[contains(@src, new_photo)]")
            end
          end
        end
      end
    end
  end
end
