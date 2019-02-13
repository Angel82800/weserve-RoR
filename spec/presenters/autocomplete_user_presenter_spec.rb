require 'rails_helper'

RSpec.describe AutocompleteUserPresenter do
  let(:user_id) { 555 }
  let(:user) { build(:user, id: user_id) }

  it 'returns presented user' do
    presenter = described_class.new(user)
    result = presenter.result

    expect(result).to eq(
      type: 'user',
      id: user.id,
      title: user.username,
      path: "/users/#{user.id}"
    )
  end
end
