require 'rails_helper'

RSpec.describe Ability, 'task' do
  let(:user)    { create(:user, :confirmed_user) }
  subject       { Ability.new(user) }


  describe 'incomplete' do
    let(:task)    { create(:task) }
    before        { allow(user).to receive(:is_project_leader_or_coordinator?).and_return(false) }

    context 'when user has no relation to the project' do
      context 'when task is reviewing' do
        before { allow(task).to receive(:reviewing?).and_return(true) }

        it do
          is_expected.not_to be_able_to(:incomplete, task)
        end
      end
    end

    context 'when user is admin' do
      before { allow(user).to receive(:admin?).and_return(true) }

      context 'when task is reviewing' do
        before { allow(task).to receive(:reviewing?).and_return(true) }

        it do
          is_expected.to be_able_to(:incomplete, task)
        end
      end
    end

    context 'when user is is_project_leader_or_coordinator of the project' do
      before { allow(user).to receive(:is_project_leader_or_coordinator?).and_return(true) }

      context 'when task is suggested' do
        before { allow(task).to receive(:suggested_task?).and_return(true) }

        it do
          is_expected.not_to be_able_to(:incomplete, task)
        end
      end

      context 'when task is reviewing' do
        before { allow(task).to receive(:reviewing?).and_return(true) }

        it do
          is_expected.to be_able_to(:incomplete, task)
        end
      end

      context 'when task is doing and deadline passed' do
        before do
          allow(task).to receive(:doing?).and_return(true)
          allow(task).to receive(:deadline).and_return(1.day.ago)
        end

        it do
          is_expected.to be_able_to(:incomplete, task)
        end
      end
    end
  end
end
