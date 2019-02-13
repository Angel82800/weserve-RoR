require 'rails_helper'

describe ProjectsController, type: :request do
  describe 'GET /projects/get_in' do
    subject(:make_request) { get('/projects/get_in', params) }
    let(:params) { { id: project.id, type: request_type } }

    let(:project) { FactoryGirl.create(:base_project, user: leader) }
    let(:user) { FactoryGirl.create(:user, email: Faker::Internet.email, confirmed_at: Time.now) }
    let(:leader) { FactoryGirl.create(:user, email: Faker::Internet.email, confirmed_at: Time.now) }
    let(:message_delivery) { instance_double(ActionMailer::MessageDelivery) }

    before { login_as(user, scope: :user, run_callbacks: false) }

    context 'when you are applying for a Lead Editor' do
      let(:request_type) { '0' }
      context 'when you are already the Lead Editor of this project' do
        before do
          # make the current user the Lead Editor of the project
          project_team = project.create_team(name: "Team#{project.id}")
          TeamMembership.create(team_member_id: user.id, team_id: project_team.id, role: 2)
        end

        it 'redirects to the project with the correct notice message', aggregate_failures: true do
          make_request

          expect(flash[:notice]).to eq(I18n.t('projects.get_in.already_lead_editor'))
          expect(response).to redirect_to(project)
        end
      end


      context 'when a request is successfully submitted' do
        before do
          allow(RequestMailer).to receive(:apply_to_get_involved_in_project).and_return(message_delivery)
          allow(message_delivery).to receive(:deliver_later)
        end


        it 'redirects to the project with the correct notice message', aggregate_failures: true do
          make_request

          expect(flash[:notice]).to eq(I18n.t('projects.get_in.success'))
          expect(response).to redirect_to(project)
        end

        it 'triggers an email to be delivered later', aggregate_failures: true do
          expect(message_delivery).to receive(:deliver_later)
          expect(RequestMailer)
            .to receive(:apply_to_get_involved_in_project).with(applicant: user, project: project, request_type: 'Lead Editor')

          make_request
        end
      end

    end

    context 'when you are applying for an coordinator' do
      let(:request_type) { '1' }
      context 'when you are already the coordinator of this project' do
        before do
          # make the current user the coordinator of the project
          project_team = project.create_team(name: "Team#{project.id}")
          TeamMembership.create(team_member_id: user.id, team_id: project_team.id, role: 3)
        end

        it 'redirects to the project with the correct notice message', aggregate_failures: true do
          make_request

          expect(flash[:notice]).to eq(I18n.t('projects.get_in.already_coordinator'))
          expect(response).to redirect_to(project)
        end
      end


      context 'when a request is successfully submitted' do
        before do
          allow(RequestMailer).to receive(:apply_to_get_involved_in_project).and_return(message_delivery)
          allow(message_delivery).to receive(:deliver_later)
        end


        it 'redirects to the project with the correct notice message', aggregate_failures: true do
          make_request

          expect(flash[:notice]).to eq(I18n.t('projects.get_in.success'))
          expect(response).to redirect_to(project)
        end

        it 'triggers an email to be delivered later', aggregate_failures: true do
          expect(message_delivery).to receive(:deliver_later)
          expect(RequestMailer)
            .to receive(:apply_to_get_involved_in_project).with(applicant: user, project: project, request_type: 'Coordinator')

          make_request
        end
      end
    end

    context 'when user has already a pending request of this type for the project' do
      let(:request_type) { '1' }
      before do
        user.apply_requests.create!(project: project, request_type: 'Coordinator')
      end

      it 'redirects to the project with the correct notice message', aggregate_failures: true do
        make_request
        expect(flash[:notice]).to eq(I18n.t('projects.get_in.already_submitted_request'))
        expect(response).to redirect_to(project)
      end
    end
  end

  describe "#create" do
    context "when logged in" do
      before do
        @picture = Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'photo.png'), 'image/png')
        @user = FactoryGirl.create(:user, email: Faker::Internet.email, confirmed_at: Time.now)
        login_as(@user, :scope => :user, :run_callbacks => false)
      end

      context 'success' do
        before do
          post '/projects', { project: { title: 'Test Proj', short_description: 'short descr', country: 'Toronto, ON, Canada', picture: @picture } }
        end

        it 'returns 302' do
          expect(response.status).to eq 302
        end

        it 'doing redirect' do
          follow_redirect!
          expect(response).to redirect_to("/projects/#{Project.last.slug}/taskstab")
        end
      end

      context 'fail' do
        context 'validates min length - 2 chars' do
          before do
            post '/projects', { project: { title: 'Test Proj 2', short_description: 'ab', country: 'Toronto, ON, Canada', picture: @picture } }
          end

          it 'returns 200' do
            expect(response.status).to eq 200
          end

          it 'assigns project errors' do
            expect(response).to render_template(:new)
            expect(controller.instance_variable_get('@project').errors.full_messages.to_sentence).to eq "Short description #{I18n.t('activerecord.errors.models.project.attributes.short_description.bad_short_description')}"
          end
        end

        context 'validates min length - 0 chars' do
          before do
            post '/projects', { project: { title: 'Test Proj 2', short_description: '', country: 'Toronto, ON, Canada', picture: @picture } }
          end

          it 'returns 200' do
            expect(response.status).to eq 200
          end

          it 'assigns project errors' do
            expect(response).to render_template(:new)
            expect(controller.instance_variable_get('@project').errors.full_messages.to_sentence).to eq "Short description can\'t be blank and Short description #{I18n.t('activerecord.errors.models.project.attributes.short_description.bad_short_description')}"
          end
        end

        context 'validates max length' do
          before do
            post '/projects', { project: { title: 'Test Proj 2', short_description: Faker::Lorem.sentence(251), country: 'Toronto, ON, Canada', picture: @picture } }
          end

          it 'returns 200' do
            expect(response.status).to eq 200
          end

          it 'assigns project errors' do
            expect(response).to render_template(:new)
            expect(controller.instance_variable_get('@project').errors.full_messages.to_sentence).to eq "Short description #{I18n.t('activerecord.errors.models.project.attributes.short_description.bad_short_description')}"
          end
        end

        context 'validates max length - too many chars' do
          before do
            post '/projects', { project: { title: 'Test Proj 2', short_description: Faker::Lorem.sentence(450), country: 'Toronto, ON, Canada', picture: @picture } }
          end

          it 'returns 200' do
            expect(response.status).to eq 200
          end

          it 'assigns project errors' do
            expect(response).to render_template(:new)
            expect(controller.instance_variable_get('@project').errors.full_messages.to_sentence).to eq "Short description #{I18n.t('activerecord.errors.models.project.attributes.short_description.bad_short_description')}"
          end
        end
      end
    end
  end

  describe 'POST /projects/change_leader' do
    subject(:make_request) { post('/projects/change_leader', params) }
    let(:params) { { project_id: project.id, leader: { address: new_leader_email } } }

    let(:project) { FactoryGirl.create(:base_project) }
    let(:user) { FactoryGirl.create(:user, email: Faker::Internet.email, confirmed_at: Time.now) }
    let(:new_leader) { FactoryGirl.create(:user, email: Faker::Internet.email, confirmed_at: Time.now) }
    let(:new_leader_email) { new_leader.email }

    before do
      login_as(user, scope: :user, run_callbacks: false)

      # make the current user as the leader
      project_team = project.create_team(name: "Team#{project.id}")
      TeamMembership.create(team_member_id: user.id, team_id: project_team.id, role: 1)
    end

    context 'when the email does not exist' do
      let(:new_leader_email) { 'does_not_exist@mail.com' }

      it 'redirects to my project with the correct error message', aggregate_failures: true do
        make_request

        expect(flash[:error]).to eq(I18n.t('projects.change_leader.email_not_found'))
        expect(response).to redirect_to(:my_projects)
      end
    end

    context 'when the project has already pending invitations for new leader' do
      before do
        project.change_leader_invitations.create!(new_leader: new_leader_email, sent_at: Time.current)
      end

      it 'redirects to my project with the correct notice message', aggregate_failures: true do
        make_request

        expect(flash[:notice]).to eq(I18n.t('projects.change_leader.already_invited'))
        expect(response).to redirect_to(:my_projects)
      end
    end

    context 'when the candidate new leader does not belong on the team members of the project' do
      it 'redirects to my project with the correct notice message', aggregate_failures: true do
        make_request

        expect(flash[:notice]).to eq(I18n.t('projects.change_leader.cannot_invite_non_team_member'))
        expect(response).to redirect_to(:my_projects)
      end
    end

    context 'when the candidate new leader is not the current user and belongs to the team' do
      let(:message_delivery) { instance_double(ActionMailer::MessageDelivery) }

      before do
        # make the candidate new leader a team member of the project
        project_team = project.create_team(name: "Team#{project.id}")
        TeamMembership.create(team_member_id: new_leader.id, team_id: project_team.id, role: 0)

        allow(InvitationMailer).to receive(:invite_leader).and_return(message_delivery)
        allow(message_delivery).to receive(:deliver_later)
        allow(NotificationsService).to receive(:notify_about_change_leader_invitation)
      end

      it 'redirects to my project with the correct notice message', aggregate_failures: true do
        make_request

        expect(flash[:notice]).to eq(I18n.t('projects.change_leader.success', email: new_leader_email) )
        expect(response).to redirect_to(:my_projects)
      end

      it 'sends an email to be delivered later', aggregate_failures: true do
        expect(InvitationMailer).to receive(:invite_leader)
        expect(message_delivery).to receive(:deliver_later)

        make_request
      end

      it 'sends a notification' do
        expect(NotificationsService).to receive(:notify_about_change_leader_invitation).with(user, new_leader, project).and_call_original

        make_request
      end
    end
  end

  describe 'PUT /projects/:id/revision_action' do
    subject(:make_request) { put("/projects/#{project.id}/revision_action", params) }
    let(:params) { { type: 'approve', rev: 1 } }
    let(:message_delivery) { instance_double(ActionMailer::MessageDelivery) }
    let(:project) { FactoryGirl.create(:project, user: leader) }
    let(:only_follower) { FactoryGirl.create(:user, :confirmed_user) }
    let(:follower_and_member) { FactoryGirl.create(:user, :confirmed_user) }
    let(:leader) { FactoryGirl.create(:user, :confirmed_user) }


    before do
      project_team = project.create_team(name: "Team#{project.id}")
      TeamMembership.create!(team_member: leader, team_id: project_team.id, role: 1)
      TeamMembership.create!(team_member: follower_and_member, team_id: project_team.id, role: 0)

      project.followers << only_follower
      project.followers << follower_and_member
      project.save!

      login_as(leader, scope: :user, run_callbacks: false)
      allow(NotificationMailer).to receive(:revision_approved).and_return(message_delivery)
      allow(message_delivery).to receive(:deliver_later)

      # This connects with mediawiki and had to be stubbed
      allow(project).to receive(:approve_revision).and_return(true)
    end


    it 'sends an email to the involved users', :aggregate_failures do
      expect(NotificationMailer).to receive(:revision_approved).exactly(2).times
      expect(message_delivery).to receive(:deliver_later).exactly(2).times
      allow_any_instance_of(Project).to receive(:notifiable_leader_and_coordinators).and_return([leader, follower_and_member])
      make_request
    end
  end


  describe 'GET /projects/show_task?id=' do

    it 'redirects user to project tasks tab in case of HTML request' do
      task = create(:task, :with_project)
      get "/projects/show_task?id=#{task.id}"
      expect(subject).to redirect_to action: :taskstab, id: task.project.id, tab: :tasks, taskId: task.id
    end
  end

  describe 'GET /projects/show_all_teams' do

    it 'redirects user to project teams tab in case of HTML request' do
      project = create(:project)
      get "/projects/show_all_teams?id=#{project.id}"
      expect(subject).to redirect_to action: :taskstab, id: project.id, tab: :team
    end
  end

  describe 'GET /projects/:id/plan' do

    it 'redirects user to project plan tab in case of HTML request' do
      project = create(:project)
      get "/projects/#{project.id}/plan"
      expect(subject).to redirect_to action: :taskstab, id: project.id, tab: :plan
    end
  end

  describe 'GET /projects/:id/read_from_mediawiki' do

    it 'redirects user to project plan tab in case of HTML request' do
      project = create(:project)
      get "/projects/#{project.id}/read_from_mediawiki"
      expect(subject).to redirect_to action: :taskstab, id: project.id, tab: :plan
    end
  end

  describe 'PUT /projects/:id/rename_subpage', vcr: { cassette_name: 'mediawiki', erb: true } do
    let(:wiki_page_name) { 'CoolProject' }
    let(:subpage_title) { 'Nice Subpage' }
    let(:incorrect_id) { project.id+1000 }
    let(:new_title) { 'New title' }

    let(:leader) { create(:user, :confirmed_user, username: 'homer') }
    let(:project) do
      project = create(:project, wiki_page_name: wiki_page_name, title: wiki_page_name, user: leader)
      project.page_write leader, ''  # this line from ProjectsCtrl#create
      project
    end
    let(:team) { create(:team, project: project) }

    let(:create_subpage) { project.subpage_write(leader, 'CONTENT', subpage_title) }
    let(:params) do
      {
          subpage_title: subpage_title,
          new_subpage_title: new_title
      }
    end

    # create 'let' statemants for users with different roles
    %w(lead_editor teammate coordinator).each do |user_type|
      let(user_type) { create(:user, :confirmed_user, username: user_type) }
      let("add_#{user_type}_to_project") { create(:team_membership, :lead_editor, team: team, team_member: send(user_type)) }
    end

    ### TESTS ####

    context "When project with ID=:id is absent in db" do
      before { put("/projects/#{incorrect_id}/rename_subpage", params) }

      it "redirects user to projects page" do
        expect(subject).to redirect_to :projects
      end
    end

    # leader and lead editor tests
    %w(leader lead_editor).each do |user_type|
      context "When user sign in as #{user_type}" do
        before do
          add_lead_editor_to_project if user_type == 'lead_editor'
          login_as(send(user_type), scope: :user, run_callbacks: false)
        end

        context "When subpage exists" do
          it "Subpage title is renamed and the response has status 200" do
            create_subpage
            put("/projects/#{project.id}/rename_subpage", params)
            expect(response.status).to eq 200
          end
        end

        context "With wrong subpage name" do
          it "Request returns status 304" do
            put("/projects/#{project.id}/rename_subpage", params.merge(subpage_title: 'wrong title'))
            expect(response.status).to eq 304
          end
        end
      end
    end

    # teammate and coordinator tests
    %w(teammate coordinator).each do |user_type|
      context "When user sign in as #{user_type}" do
        before do
          send("add_#{user_type}_to_project")
          login_as(send(user_type), scope: :user, run_callbacks: false)
        end

        context "When subpage exists" do
          it "Subpage title does not rename and the response has status 304" do
            create_subpage
            put("/projects/#{project.id}/rename_subpage", params)
            expect(response.status).to eq 304
          end
        end
      end
    end

  end
end
