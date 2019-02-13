require 'rails_helper'

RSpec.describe Stripe do
 let(:user1) { FactoryGirl.create(:user, confirmed_at: Time.now) }

  describe '#create charge for user' do
    it 'create charge for 3000 cents' do
      VCR.use_cassette "charge_with_3000_cents" do
        Payments::Stripe.new(stripe_token: "tok_visa", user: user1).direct_charge!(3000, false)
        expect(PaymentTransaction.count).to eq(1)
      end
    end
    it 'should not allow, if fund is less than minimum task budget' do
      VCR.use_cassette "charge with 1000 cents" do
        arr = Payments::Stripe.new(stripe_token: "tok_visa", user: user1).direct_charge!(1000, false)
        expect(arr).to eq(false)
      end
    end
  end

  describe "# custom account" do
    it 'create user custom account' do
      VCR.use_cassette ("custom_account") do
        para_hash = {country: "US", city: "Chicago", line1: "445 Rebecca Street", state: "IL", postal_code: "60607",
          first_name: "Denis", type: "individual", last_name: "Joubert", dob: "20-02-1992", ssn_last_4_provided: true,
          ip: "66.249.64.28", ssn_last_4: "1234"}
        acct_id = Payments::Stripe.create_custom_acc(para_hash)
        expect(acct_id).to be_truthy
      end
    end
  end
end
