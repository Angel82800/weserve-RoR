require 'rails_helper'

RSpec.describe UserErrorPresenter do
  it "returns original error message if error type was not found" do
    error = StandardError.new("some error")
    expect(described_class.new(error).message).to eq(error.message)
  end

  it "returns original error message if error type was found but error message has no matches" do
    error = Payments::BTC::Errors::TransferError.new("Unknown error")
    expect(described_class.new(error).message).to eq(error.message)
  end

  it "returns substitution message if match was found" do
    error = Payments::BTC::Errors::TransferError.new("Not found")
    expect(described_class.new(error).message).to eq("Not enough funds on the balance to perform this operation")
  end
end
