require 'rails_helper'

RSpec.describe Project, type: :model do
  # Association
  it { is_expected.to have_one(:team) }
  it { is_expected.to have_many(:team_members).through(:team) }
  it { is_expected.to have_many(:team_memberships).through(:team) }

  describe 'short_description validation' do
    let(:project) { create(:project) }

    context 'errors' do
      it 'validates min length - 2 chars' do
        project.short_description = 'ab'
        expect { project.save! }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Short description #{I18n.t('activerecord.errors.models.project.attributes.short_description.bad_short_description')}")
      end

      it 'validates min length - 0 chars' do
        project.short_description = ''
        expect { project.save! }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Short description can\'t be blank, Short description #{I18n.t('activerecord.errors.models.project.attributes.short_description.bad_short_description')}")
      end

      it 'validates max length' do
        project.short_description = Faker::Lorem.sentence(251)
        expect { project.save! }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Short description #{I18n.t('activerecord.errors.models.project.attributes.short_description.bad_short_description')}")
      end

      it 'validates max length - too many chars' do
        project.short_description = Faker::Lorem.sentence(400)
        expect { project.save! }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Short description #{I18n.t('activerecord.errors.models.project.attributes.short_description.bad_short_description')}"  )
      end
    end

    context 'success' do
      it 'validates allowed length' do
        project.short_description = 'abcd'
        expect(project.save!).to be true
      end

      it 'validates allowed length - maximum 250' do
        project.short_description = Faker::Lorem.characters(250)
        expect(project.save!).to be true
      end
    end
  end

  describe 'Slug validations' do
    let(:title) { 'Cool title' }
    let(:slug) { 'custom-slug' }
    let(:new_slug) { 'new-slug' }

    it { is_expected.to validate_presence_of(:slug) }
    it { is_expected.to validate_uniqueness_of(:slug) }

    context 'When save new project' do
      it 'ensure slug' do
        project = create(:project, slug: nil)
        project.reload
        expect(project.slug).to_not be_nil
      end
    end

    it 'prevent slug duplications' do
      project = create(:project, title: title)
      another_project = build(:project, title: title)
      another_project.save(validate: false)  # skip title validations
      project.reload
      another_project.reload
      expect(another_project.slug).to_not eq(project.slug)
    end

    it 'slug can be changed' do
      project = create(:project, slug: slug)
      project.update(slug: new_slug)
      project.reload
      expect(project.slug).to eq(new_slug)
    end
  end

  describe '#interested_users' do
    let(:project) { FactoryGirl.create(:project, user: leader) }
    let(:only_follower) { FactoryGirl.create(:user, :confirmed_user) }
    let(:follower_and_member) { FactoryGirl.create(:user, :confirmed_user) }
    let(:leader) { FactoryGirl.create(:user, :confirmed_user) }

    before do
      project_team = project.create_team(name: "Team#{project.id}")
      TeamMembership.create!(team_member: follower_and_member, team_id: project_team.id, role: 0)

      project.followers << only_follower
      project.followers << follower_and_member
      project.save!
    end

    it 'returns the the interested users only once' do
      expect(project.reload.interested_users).to contain_exactly(follower_and_member, leader)
    end
  end

  describe 'MediaWiki API actions',
           vcr: { cassette_name: 'mediawiki', erb: true,
                  match_requests_on: [:path, :query] } do
    let(:project) { create(:project, wiki_page_name: 'test') }

    describe '.page_read' do
      subject { project.page_read }

      context 'without username' do
        it 'returns a success result' do
          expect(subject['status']).to eq 'success'
          expect(subject['revision_id']).to eq 72
          expect(subject['non-html']).to eq 'hello'
          expect(subject['html']).to eq "<p>hello\n</p>"
          expect(subject['is_blocked']).to eq 0
        end
      end

      context 'with username' do
        subject { project.page_read('homer') }
        it 'returns a success result' do
          expect(subject['status']).to eq 'success'
          expect(subject['revision_id']).to eq 72
          expect(subject['non-html']).to eq 'hello'
          expect(subject['html']).to eq "<p>hello\n</p>"
          expect(subject['is_blocked']).to eq 0
        end
      end

      context 'unknown page' do
        let(:project) { create(:project, wiki_page_name: 'unknown page') }
        it { expect(subject['status']).to eq 'error' }
      end
    end

    describe '.page_write' do
      let(:user) { create(:user, username: 'homer') }
      subject { project.page_write(user, 'a test') }

      it { is_expected.to eq 200 }
    end

    describe '.get_latest_revision' do
      subject { project.get_latest_revision }

      it { is_expected.to eq 'a test' }
    end

    describe '.get_history' do
      subject { project.get_history }

      it 'returns an array with revisions' do
        expect(subject).not_to be_nil
        expect(subject.count).to eq 5
      end
    end

    describe '.get_revision' do
      subject { project.get_revision(627) }

      it 'returns the specific revision' do
        expect(subject['parent_id']).to eq 586
        expect(subject['author']).to eq 'Homer'
        expect(subject['timestamp']).to eq '1496099755'
        expect(subject['comment']).to eq ''
        expect(subject['diff']).to eq(-3)
        expect(subject['content']).to eq 'a test'
        expect(subject['status']).to eq 'unknown'
      end
    end

    describe '.approve_revision' do
      subject { project.approve_revision(627) }

      it { is_expected.to eq 200 }
    end

    describe '.unapprove_revision' do
      subject { project.unapprove_revision(627) }

      it { is_expected.to eq 200 }
    end

    describe '.unapprove' do
      subject { project.unapprove }

      it { is_expected.to eq 200 }
    end

    describe '.block_user' do
      subject { project.block_user('homer') }

      it { is_expected.to eq 200 }
    end

    describe '.unblock_user' do
      subject { project.unblock_user('homer') }

      it { is_expected.to eq 201 }
    end

    describe '.rename_page' do
      let(:project) { create(:project, wiki_page_name: 'New Test') }
      subject { project.rename_page('homer', 'Test') }

      it { is_expected.to eq 200 }
    end

    describe '.subpage_rename' do
      let(:wiki_page_name) { 'CoolProject' }
      let(:subpage_title) { 'Nice Subpage' }
      let(:project) { create(:project, wiki_page_name: wiki_page_name, title: wiki_page_name) }
      subject { project.subpage_rename('homer', subpage_title, 'New title') }

      it { is_expected.to eq 200 }
    end

    describe '.grant_permissions' do
      subject { project.grant_permissions('homer') }

      it { is_expected.to eq 200 }
    end

    describe '.revoke_permissions' do
      subject { project.revoke_permissions('homer') }

      it { is_expected.to eq 200 }
    end

    describe '.archive' do
      subject { project.archive('homer') }

      it { is_expected.to eq 200 }
    end

    describe '.unarchive' do
      subject { project.unarchive('homer') }

      it { is_expected.to eq 200 }
    end
  end

  describe '.add_team_member' do
    let(:user) { create(:user) }
    let(:project) { create(:project) }
    let(:last_membership) { TeamMembership.last }

    before { project.add_team_member(user) }

    context 'user is not included in members list' do
      it { expect(project.team_members.size).to eq 2 }
      it { expect(project.team_members).to include(user) }
      it { expect(last_membership.team_member).to eq user }
      it { expect(last_membership[:role]).to eq TeamMembership::TEAM_MATE_ID }
    end

    context 'user is already in members list' do
      let(:user) { project.user }

      it { expect(project.team_members.size).to eq 1 }
      it { expect(project.team_members).to include(user) }
    end
  end

  describe '.team_relations_string' do
    let(:user) { project.user }
    let(:project) { create(:project) }
    let(:team) { create(:team, project: project) }

    context 'one user' do
      it 'with one role' do
        expect(project.team_relations_string).to eq(User.all.count.to_s + ' / ' + project.tasks.sum(:target_number_of_participants).to_s)
      end
      it 'with more roles' do
        team.team_memberships << TeamMembership.new(
          team: team, team_member: user, role: TeamMembership::COORDINATOR_ID
        )
        expect(project.team_relations_string).to eq(User.all.count.to_s + ' / ' + project.tasks.sum(:target_number_of_participants).to_s)
      end
    end

    context 'two users' do
      let(:user2) { create(:user) }
      before { project.add_team_member(user2) }

      it 'one role each' do
        expect(project.team_relations_string).to eq(User.all.count.to_s + ' / ' + project.tasks.sum(:target_number_of_participants).to_s)
      end
      it 'more roles each' do
        team.team_memberships << TeamMembership.new(
          team: team, team_member: user, role: TeamMembership::COORDINATOR_ID
        )
        team.team_memberships << TeamMembership.new(
          team: team, team_member: user2, role: TeamMembership::LEAD_EDITOR_ID
        )
        expect(project.team_relations_string).to eq(User.all.count.to_s + ' / ' + project.tasks.sum(:target_number_of_participants).to_s)
      end
    end

  end

  describe '.notifiable_leader_and_coordinators' do
    let(:project) { FactoryGirl.create(:project, user: leader) }
    let(:follower_and_coordinator) { FactoryGirl.create(:user, :confirmed_user) }
    let(:leader) { FactoryGirl.create(:user, :confirmed_user) }

    before do
      project_team = project.create_team(name: "Team#{project.id}")
      TeamMembership.create!(team_member: follower_and_coordinator, team_id: project_team.id, role: TeamMembership::COORDINATOR_ID)
      project.save!
    end

    it 'returns the the interested users only once' do
      expect(project.reload.notifiable_leader_and_coordinators).to contain_exactly(leader, follower_and_coordinator )
    end

    it "returns leader and coordinator if they follow project"  do
      project.followers = [leader]
      project.save!
      expect(project.reload.notifiable_leader_and_coordinators).to contain_exactly(leader)
    end
  end

end
