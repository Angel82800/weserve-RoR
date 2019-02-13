# frozen_string_literal: true
require 'rails_helper'

feature 'Attach a file to a Task', js: true do
  let(:leader_user) { create(:user, :confirmed_user) }
  let(:admin) { create(:user, :confirmed_user, admin: true) }
  let(:project) { create(:project, user: leader_user) }
  let!(:task) { create(:task, project: project) }

  context 'As project leader' do
    before { login_as(leader_user, scope: :user, run_callbacks: false) }

    context 'When you navigate to the task modal of a project' do
      before do
        visit project_path(project)
        find("ul.m-tabs li a[data-tab='tasks']").trigger('click')
        wait_for_ajax

        all("[data-task-id='#{task.id}']").first.click
      end

      scenario 'Then the task modal appeared' do
        expect(find('#myModal')).to be_visible
      end

      context 'When you attach a file to a task' do
        before do
          find('#new_task_attachment').attach_file(
            'task_attachment[attachment]',
            "#{Rails.root}/spec/fixtures/photo.png"
          )
          wait_for_ajax
        end

        scenario 'Then the attachment is available to download' do
          within '#task-attachments-div' do
            expect(page).to have_content 'photo.png'
            expect(page).to have_content 'Open'
            expect(page).to have_content 'Remove'
          end
        end

        context 'When you click the button to remove attachment' do
          before do
            within '#task-attachments-div' do
              click_link 'Remove'
              wait_for_ajax
            end
          end

          # scenario 'Then the attachment has been removed' do
          #   within '#task-attachments-div' do
          #     expect(page).not_to have_content 'photo.png'
          #   end
          # end
        end
      end
    end
  end

  context 'As project admin' do
    before { login_as(admin, scope: :user, run_callbacks: false) }

    context 'When you navigate to the task modal of a project' do
      before do
        visit project_path(project)
        find("ul.m-tabs li a[data-tab='tasks']").trigger('click')
        wait_for_ajax

        all("[data-task-id='#{task.id}']").first.click
      end

      scenario 'Then the task modal appeared' do
        expect(find('#myModal')).to be_visible
      end

      context 'When you attach a file to a task' do
        before do
          find('#new_task_attachment').attach_file(
            'task_attachment[attachment]',
            "#{Rails.root}/spec/fixtures/photo.png"
          )
          wait_for_ajax
        end

        scenario 'Then the attachment is available to download' do
          within '#task-attachments-div' do
            expect(page).to have_content 'photo.png'
            expect(page).to have_content 'Open'
            expect(page).to have_content 'Remove'
          end
        end

        context 'When you click the button to remove attachment' do
          before do
            within '#task-attachments-div' do
              click_link 'Remove'
              wait_for_ajax
            end
          end

          # scenario 'Then the attachment has been removed' do
          #   within '#task-attachments-div' do
          #     expect(page).not_to have_content 'photo.png'
          #   end
          # end
        end
      end
    end
  end

  context 'As anonymous' do
    let!(:task_attachment) { create(:task_attachment, task: task) }
    let!(:task) { create(:task, project: project) }

    context 'When you navigate to the task modal of a project' do
      before do
        visit project_path(project)
        find("ul.m-tabs li a[data-tab='tasks']").trigger('click')
        wait_for_ajax

        all("[data-task-id='#{task.id}']").first.click
      end

      scenario 'Then the attachment is available to download' do
        within '#task-attachments-div' do
          expect(page).to have_content 'photo.png'
          expect(page).to have_content 'Open'
        end
      end

      scenario 'Then the attachment is not available to remove' do
        within '#task-attachments-div' do
          expect(page).not_to have_content 'Remove'
        end
      end
    end
  end
end
