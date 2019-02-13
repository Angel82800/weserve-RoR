require 'rails_helper'

describe  ApplicationHelper do

  it 'shows btc in 4 decimals' do
    expect(btc_balance(3.452678)).to eq 3.4527
  end

  it 'shows cents balance in usd with 2 decimals' do
    expect(balance_in_usd(2334)).to eq 23.34
  end

end
