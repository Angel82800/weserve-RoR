require 'rails_helper'

describe TaskObserver do
  subject { TaskObserver.instance }
  let(:task) { build(:task, :suggested) }

  it 'calls #after_create when new task are created' do
    expect(subject).to receive(:after_create).with(task)
    Task.observers.enable :task_observer do
      task.save
    end
  end

  describe '.after_create' do
    context 'when a new task is suggested' do
      let(:suggestor) { create(:user, :confirmed_user) }
      let(:follower) { create(:user, :confirmed_user) }
      let(:task) { create(:task, :suggested, user: suggestor) }
      let(:notification) { double :notification }

      it 'sends an email to project user' do
        expect(NotificationMailer).to receive(:suggest_task).with(task.project.user, task).and_return(notification)
        expect(notification).to receive(:deliver_later)
        # task.save
        subject.after_create(task)
      end

      it 'sends email to project followers' do
        task.project.followers << follower
        expect(NotificationMailer).to receive(:suggest_task).with(task.project.user, task).and_return(notification)
        expect(NotificationMailer).to receive(:suggest_task).with(follower, task).and_return(notification)
        expect(notification).to receive(:deliver_later).twice
        # task.save
        subject.after_create(task)
      end

      it 'doesnot sends an email to suggestor' do
        task.project.followers << task.user
        expect(notification).to receive(:deliver_later)
        expect(NotificationMailer).to receive(:suggest_task).with(task.project.user, task).and_return(notification)
        # task.save
        subject.after_create(task)
      end
    end
  end
end