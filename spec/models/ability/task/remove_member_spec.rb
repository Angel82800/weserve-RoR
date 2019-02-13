require 'rails_helper'

RSpec.describe Ability, 'task' do
  let(:user)    { create(:user, :confirmed_user) }
  subject       { Ability.new(user) }

  describe 'remove_member' do
    let(:task)    { create(:task, :with_project) }
    before        { allow(user).to receive(:is_project_leader_or_coordinator?).and_return(false) }

    context 'when user has no relation to the project' do
      context 'when task is pending' do
        before { allow(task).to receive(:state).and_return('suggested_task') }

        it do
          is_expected.not_to be_able_to(:remove_member, task)
        end
      end
    end

    context 'when user is admin' do
      before { allow(user).to receive(:admin?).and_return(true) }

      context 'when task is pending' do
        before { allow(task).to receive(:state).and_return('suggested_task') }

        it do
          is_expected.to be_able_to(:remove_member, task)
        end
      end

      context 'when task is accepted' do
        before { allow(task).to receive(:state).and_return('accepted') }

        it do
          is_expected.to be_able_to(:remove_member, task)
        end
      end

      context 'when task is incompleted' do
        before { allow(task).to receive(:state).and_return('incompleted') }

        it do
          is_expected.to be_able_to(:remove_member, task)
        end
      end

      context 'when task is rejected' do
        before { allow(task).to receive(:state).and_return('rejected') }

        it do
          is_expected.not_to be_able_to(:remove_member, task)
        end
      end

      context 'when task is completed' do
        before { allow(task).to receive(:state).and_return('completed') }

        it do
          is_expected.not_to be_able_to(:remove_member, task)
        end
      end

      context 'when task is reviewing' do
        before { allow(task).to receive(:state).and_return('reviewing') }

        it do
          is_expected.not_to be_able_to(:remove_member, task)
        end
      end

      context 'when task is doing' do
        before { allow(task).to receive(:state).and_return('doing') }

        it do
          is_expected.not_to be_able_to(:remove_member, task)
        end
      end
    end

    context 'when user is project leader or coordinator of the task project' do
      before do
        allow(user).to receive(:is_project_leader?).and_return(true)
        allow(user).to receive(:is_lead_editor_for?).and_return(true)
      end

      context 'when task is pending' do
        before { allow(task).to receive(:state).and_return('suggested_task') }

        it do
          is_expected.to be_able_to(:remove_member, task)
        end
      end

      context 'when task is rejected' do
        before { allow(task).to receive(:state).and_return('rejected') }

        it do
          is_expected.not_to be_able_to(:remove_member, task)
        end
      end
    end
  end
end
