# # frozen_string_literal: true
# require 'rails_helper'
#
# feature 'Project boards', js: true do
#   let(:leader_user) {create(:user, :confirmed_user)}
#   let(:project) {create(:project, user: leader_user)}
#   let(:default_board) {project.boards.first}
#   let!(:task) {create(:task, project: project)}
#
#   context 'As project leader' do
#     before {login_as(leader_user, scope: :user, run_callbacks: false)}
#
#     context 'When you navigate to the task modal of a project' do
#       before do
#         visit taskstab_project_path(project)
#         find("ul.m-tabs li a[data-tab='tasks']").trigger('click')
#         wait_for_ajax
#         @boards_div = find('.boards')
#       end
#
#       scenario 'Then the default board appeared' do
#         expect(@boards_div).to have_content I18n.t('activerecord.board.default_title')
#       end
#
#       scenario 'Then the button to create new boards appeared' do
#         expect(@boards_div).to have_link I18n.t('boards.boards_with_tasks.new_board_link')
#       end
#
#       context 'And you click the button to create new boards' do
#         before do
#           click_link(I18n.t('boards.boards_with_tasks.new_board_link'))
#           wait_for_ajax
#         end
#
#         scenario 'Then the new board modal is visible' do
#           expect(find('#newBoard')).to be_visible
#         end
#
#         context 'And you create a new board' do
#           before do
#             within '#newBoard' do
#               fill_in 'board[title]', with: 'A new board'
#               click_button 'Send'
#               wait_for_ajax
#             end
#           end
#
#           scenario 'Then the new board is displayed' do
#             expect(@boards_div).to have_content 'A new board'
#             expect(project.boards.reload.count).to eq 2
#           end
#
#           scenario 'Then the link to edit board appeared' do
#             expect(@boards_div).to have_link 'Edit Board'
#           end
#
#           scenario 'Then the link to remove board appeared' do
#             expect(@boards_div).to have_css('div#removeBoard')
#           end
#
#           # After delete and redirecting to index I'm receiving this same issue
#           # https://github.com/thoughtbot/capybara-webkit/issues/874
#           # context 'And you click the remove button for the new board', focus: true do
#           #   let(:new_board) { project.boards.reload.last }
#
#           #   before do
#           #     @new_board_div = find("#project-board-#{new_board.id}")
#           #     within @new_board_div do
#           #       click_link('Remove Board')
#           #       wait_for_ajax
#
#           #       visit project_path(project)
#           #       binding.pry
#           #       wait_for_ajax
#           #       sleep(2)
#           #       find("ul.m-tabs li a[data-tab='tasks']").trigger('click')
#           #       wait_for_ajax
#           #       @boards_div = find('.boards')
#           #     end
#           #   end
#
#           #   scenario 'Then the new board is displayed' do
#           #     expect(@boards_div).not_to have_content 'A new board'
#           #     expect(project.boards.reload.count).to eq 1
#           #   end
#           # end
#
#
#           context 'And you click the link to edit board' do
#             before do
#               find("span#project-board-#{project.boards.last.id}").hover
#               click_link('Edit Board')
#               wait_for_ajax
#               @edit_div = find("#editBoard-#{project.boards.last.id}")
#             end
#
#             scenario 'Then the edit modal is visible' do
#               expect(@edit_div).to be_visible
#             end
#
#             context 'And you fill the board fields' do
#               before do
#                 within @edit_div do
#                   fill_in 'board[title]', with: 'The board was changed'
#                   click_button 'Send'
#                   wait_for_ajax
#                 end
#               end
#
#               scenario 'Then the new board is displayed' do
#                 expect(@boards_div).to have_content 'The board was changed'
#                 expect(@boards_div).to have_content 'Main Board'
#               end
#             end
#           end
#         end
#       end
#     end
#   end
#
#
#   context 'As anonymous' do
#     context 'When you navigate to the task modal of a project' do
#       before do
#         visit taskstab_project_path(project)
#         find("ul.m-tabs li a[data-tab='tasks']").trigger('click')
#         wait_for_ajax
#         @boards_div = find('.boards')
#       end
#
#       scenario 'Then the default board appeared' do
#         expect(@boards_div).to have_content 'Main Board'
#       end
#
#       scenario 'Then the link to create new boards is not available' do
#         expect(@boards_div).not_to have_link 'Create a new Board'
#       end
#
#       scenario 'Then the link to edit board is not available' do
#         expect(@boards_div).not_to have_link 'Edit Board'
#       end
#
#       scenario 'Then the link to remove board is not available' do
#         expect(@boards_div).not_to have_link 'Remove Board'
#       end
#     end
#   end
# end
