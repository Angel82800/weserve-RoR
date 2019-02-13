require 'rails_helper'

feature 'My Projects', js: true do
  let(:user)      { create(:user, :confirmed_user) }

  before { login_as(user, scope: :user, run_callbacks: false) }


  context 'click on My Projects from the top right corner of the page' do
=begin
    context 'my projects' do
      let(:project)   { create(:project, user: user, id: 222) }

      before do
        visit my_projects_url
      end

      scenario 'belonging project listed in my projects section' do
        my_projects_section = find('.my-projects')

        expect(my_projects_section).to have_content(project.title)
      end

      scenario 'shows project detail' do
        project_container = find('.my-projects #project-222')

        expect(project_container).to have_content(project.title)
        expect(project_container).to have_content(user.display_name)

        expect(project_container).to have_content(user.funded_budget.to_f.round(4))
        expect(project_container).to have_content(user.needed_budget.to_f.round(4))

        expect(project_container).to have_content(user.funded_percentages)
        expect(project_container).to have_content(user.team_relations_string)
        expect(project_container).to have_content(user.tasks_relations_string)
        expect(project_container).to have_content(user.accepted_tasks)
        expect(project_container).to have_content(user.tasks.count)

        expect(project_container).to has_selector('i.fa-trash-o')
      end
    end
=end

    context 'followed projects' do
      let(:project)   { create(:project, id: 333) }

      before do
        project.follow!(user)
        visit my_projects_url
      end

# TODO: update spec after followed projects bug will be fixed
=begin
      scenario 'followed project listed in followed projects section' do
        followed_projects_section = find('ul.followed-projects')

        expect(followed_projects_section).to have_content(project.title)
      end

      scenario 'shows project detail' do
        project_container = find('.followed-projects #project-333')

        expect(project_container).to have_content(project.title)
        expect(project_container).to have_content(user.display_name)

        expect(project_container).to have_content(user.funded_budget.to_f.round(4))
        expect(project_container).to have_content(user.needed_budget.to_f.round(4))

        expect(project_container).to have_content(user.funded_percentages)
        expect(project_container).to have_content(user.team_relations_string)
        expect(project_container).to have_content(user.tasks_relations_string)
        expect(project_container).to have_content(user.accepted_tasks)
        expect(project_container).to have_content(user.tasks.count)

        expect(project_container).not_to have_selector('i.fa-trash-o')
      end
=end
    end
  end
end
