require 'rails_helper'

RSpec.describe Payments::StripeController do
  let(:user) do
    user = create(:user, :confirmed_user, username: 'taskuser')
    user.admin!
    user
  end

  let(:project) do
    FactoryGirl.create(:project, user: user)
  end

  let(:task) do
    FactoryGirl.create(:task, project: project)
  end

  before do
    sign_in(user)
  end

  describe '#create' do
    before { post(:create, create_params) }

    context 'stripe charge with valid parameters' do
      VCR.use_cassette ("charge_with_3000_cents") do
        let(:create_params) do
          { stripeToken: "STRIPE_TOKEN_FOR_QA", amount: 200 , save_card: 1, project_id: project.id, id: task.id}
        end
        it { expect(response.status).to eq(403) }
      end
    end
  end

end