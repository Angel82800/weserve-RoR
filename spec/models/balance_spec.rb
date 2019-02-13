require 'rails_helper'

RSpec.describe Balance, type: :model do
  subject { FactoryGirl.create :balance }
  it '#amount_in_dolars' do
    expect(subject.amount_in_dollars).to be 100.0
  end
  describe 'user balance' do
    let(:user) { FactoryGirl.create :user }
    let(:balance) { FactoryGirl.create :balance, user: user }
    it '#parent' do
      expect(balance.parent.class).to be User
    end
    it '#funded' do
      expect do
        balance.funded
      end.to raise_error StandardError
    end
  end

  describe 'task balance' do
    let(:user) { FactoryGirl.create :user }
    let(:project) { FactoryGirl.create :project }
    let(:task) { FactoryGirl.create :task, project: project, user: user }
    let(:balance) { FactoryGirl.create :balance, task: task }
    let(:message_delivery) { instance_double(ActionMailer::MessageDelivery) }

    before do
      allow(message_delivery).to receive(:deliver_later)
      allow(NotificationMailer).to receive(:task_started).and_return(message_delivery)
    end

    it '#parent' do
      expect(balance.parent.class).to be Task
    end
    it '#funded' do
      expect(balance.funded).to be 0
    end

    context 'when the task is eligible to move to doing' do
      before { task.update(number_of_participants: task.target_number_of_participants) }

      it '#update_state_task' do
        expect{balance.update(funded: task.budget)}.to change(task, :state).from("accepted").to("doing")
      end

      it 'sends an email to the involved users', :aggregate_failures do
        expect(task.project.interested_users.count).to eq(1)
        expect(NotificationMailer).to receive(:task_started).exactly(1).times
        balance.update(funded: task.budget)
      end
    end

    it 'when the task has not enough participants' do
      expect{balance.update(funded: task.budget)}.to_not change(task, :state)
    end

    it 'when the task has not enough funds', aggregate_failures: true do
      task.update(number_of_participants: task.target_number_of_participants)
      expect{balance.update(funded: task.budget - 1)}.to_not change(task, :state)
    end
  end
end
