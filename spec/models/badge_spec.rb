require 'rails_helper'

RSpec.describe Badge, type: :model do
  describe '#Association' do
    it { should belong_to(:user) }
    it { should belong_to(:project) }
  end

  describe 'assign badges to user' do
    context 'assign donor badge' do
      let(:project) { FactoryGirl.create(:project) }
      let(:user) { project.user }
      let(:task) { FactoryGirl.create(:task,user: user, project:project) }
      let(:payment_attributes){ { id: 4, amount: 100, task_id: task.id, user_id: user.id, payment_type: :card, payment_token: 'payment_token', processing_fee: '5', status: PaymentTransaction.statuses[:completed] } }

      it 'create payment' do
        PaymentTransaction.create(payment_attributes)
        expect(user.badges.count).to eq 1
        expect(project.badges.count).to eq 1
        expect(project.badges.last.badge_type).to eq 'donor'
      end
    end

  end
end
