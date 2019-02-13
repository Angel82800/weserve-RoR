require 'rails_helper'

RSpec.describe Task, :type => :model do
  describe "validations" do
    it "is not possible to create a task without a deadline" do
      expect {
        create(:task, deadline: nil)
      }.to raise_error(
        ActiveRecord::RecordInvalid,
        "Validation failed: Deadline can't be blank"
      )
    end

    it "is not possible to set a nil deadline for a valid task" do
      task = create(:task, deadline: "2017-03-24 11:17:46 UTC")
      task.deadline = nil
      expect(task.save).to be false
    end

    it "is possible to create a task with a deadline" do
      task = create(:task, deadline: "2017-03-24 11:17:46 UTC")
      expect(task).to be_persisted
    end

    it "is not possible to create a task with a budget lower than the minimum specified" do
      expect {
        create(:task, budget: Task::MINIMUM_FUND_BUDGET - 1)
      }.to raise_error(
        ActiveRecord::RecordInvalid,
        "Validation failed: Budget must be greater than or equal to " + Task::MINIMUM_FUND_BUDGET.to_s
      )
    end

    it "is possilbe to create a task with a correct budget" do
      task = build(:task, budget: Task::MINIMUM_FUND_BUDGET - 1)
      expect(task.save).to be false
      task.budget = Task::MINIMUM_FUND_BUDGET
      expect(task.save).to be true
    end

    it "is not possible to set a nil budget for a valid task" do
      task = create(:task)
      task.budget = nil
      task.valid?
      expect(task.errors.messages.keys).to eq([:budget])
    end

    it "is not possible to set a budget that is lower than the minimum specified for a vaild task" do
      task = create(:task)
      task.budget = Task::MINIMUM_FUND_BUDGET - 1
      task.valid?
      expect(task.errors.messages.keys).to eq([:budget])
    end
  end

  describe 'state transitions' do
    describe '#reject' do
      it { is_expected.to transition_from(:suggested_task).to(:rejected).on_event(:reject) }
      it { is_expected.to transition_from(:accepted).to(:rejected).on_event(:reject) }
    end
  end

  describe 'task creation with balance' do
    it 'creates a balance for a task if with_balance trait is used' do
      task = create(:task, :with_balance)
      task.reload
      expect(task.balance).to be_present
    end
  end

  describe '#funds_needed_to_fulfill_budget' do
    it "returns budget if there is no any funding" do
      task = create(:task, budget: 2000)
      expect(task.funds_needed_to_fulfill_budget).to eq(2000)
    end

    it "returns difference between budget and current_fund" do
      task = create(:task,:with_balance, budget: 2000, current_fund: 1000)
      expect(task.funds_needed_to_fulfill_budget).to eq(1000)
    end

    it "returns zero if task 100% funded" do
      task = create(:task, :with_balance, budget: 2000, current_fund: 2000)
      expect(task.funds_needed_to_fulfill_budget).to eq(0)
    end

    it "returns zero if task funded for the more than 100%" do
      task = create(:task, :with_balance, budget: 2000, current_fund: 3000)
      expect(task.funds_needed_to_fulfill_budget).to eq(0)
    end

    it "returns zero if task is already completed" do
      task = create(:task, :with_balance, :completed, budget: 2000, current_fund: 0)
      expect(task.funds_needed_to_fulfill_budget).to eq(0)
    end
  end

  describe '#activities' do
    let!(:task) { create(:task) }

    let!(:task_activity)          { create(:activity, targetable: task) }
    let!(:task_comment_activity)  { create(:activity, :task_comment, task: task) }
    let!(:task_assignee_activity) { create(:activity, :team_membership, task: task) }

    before do
      team_membership =  task_assignee_activity.targetable
      team_membership.update(deleted_reason: 'replace new assignee')
      team_membership.destroy
    end

    it do
      expect(task.activities).to include(task_activity)
      expect(task.activities).to include(task_comment_activity)
      expect(task.activities).to include(task_assignee_activity)
    end
  end

  describe '.interested_users' do
    let(:project) { FactoryGirl.create(:project, user: leader) }
    let(:only_follower) { FactoryGirl.create(:user, :confirmed_user) }
    let(:member) { FactoryGirl.create(:user, :confirmed_user) }
    let(:leader) { FactoryGirl.create(:user, :confirmed_user) }
    let!(:task) { create(:task, project: project) }

    before do
      project_team = project.create_team(name: "Team#{project.id}")
      TeamMembership.create!(team_member: member, team_id: project_team.id, role: 0)

      project.followers << member
      project.save!
      Assignment.create(task_id: task.id, user_id: member.id, state: :accepted)
    end

    it "returns only followers and assigned users" do
      expect(task.interested_users).to eq([leader, member])
    end
  end
end
