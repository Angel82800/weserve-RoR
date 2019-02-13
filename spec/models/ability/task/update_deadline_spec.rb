require 'rails_helper'

RSpec.describe Ability, 'task' do
  let(:user)    { create(:user, :confirmed_user) }
  subject       { Ability.new(user) }

  describe 'update_deadline' do
    let(:task)    { create(:task) }
    before        { allow(user).to receive(:is_project_leader_or_coordinator?).and_return(false) }

    context 'when user is admin' do
      before { allow(user).to receive(:admin?).and_return(true) }

      context 'when task is not incompleted' do
        before { allow(task).to receive(:any_fundings?).and_return(true) }
        before { allow(task).to receive(:incompleted?).and_return(false) }

        it do
          is_expected.not_to be_able_to(:update_deadline, task)
        end
      end

      context 'when task is incompleted' do
        before { allow(task).to receive(:incompleted?).and_return(true) }

        it do
          is_expected.to be_able_to(:update_deadline, task)
        end
      end
    end

    context 'when user is_project_leader_or_coordinator of the project' do
      before { allow(user).to receive(:is_project_leader_or_coordinator?).and_return(true) }

      context 'when task is not incompleted' do
        # Assign task some funding to fail other case
        before { allow(task).to receive(:any_fundings?).and_return(true) }
        before { allow(task).to receive(:incompleted?).and_return(false) }

        it do
          is_expected.not_to be_able_to(:update_deadline, task)
        end
      end

      context 'when task is incompleted' do
        before { allow(task).to receive(:incompleted?).and_return(true) }

        it do
          is_expected.to be_able_to(:update_deadline, task)
        end
      end
    end
  end
end
