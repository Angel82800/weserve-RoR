class AutocompleteUserPresenter < ApplicationPresenter
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def result
    {
      type: 'user',
      id: user.id,
      title: user.username || '',
      path: path
    }
  end

  private

  def path
    url_helpers.user_path(user.id)
  end
end
