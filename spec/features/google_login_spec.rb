require 'rails_helper'

feature 'Google login', js: true do
  before do
    visit '/'
    find(".auth_links .sign_in_a").trigger("click")

    @modal = find('div#registerModal', visible: true)
  end

  scenario "Sign in popup appeared when click login link" do
    expect(@modal).to be_visible
  end

  context "as already registered user" do
    before do
      @user = FactoryGirl.create(:user, confirmed_at: Time.now)

      click_google_login(@user)
    end

    scenario "log in with the user's google account" do
      expect(page).to have_selector("span.user-dropdown__name")
    end
  end

  context "as new user" do
    before(:each) do
      @user = FactoryGirl.build(:user)

      @before_count = User.count

      click_google_login(@user)
    end

    scenario "registered with the user's google account" do
      expect(User.count).not_to eq @before_count
    end

    scenario "log in with the user's google account" do
      expect(page).to have_selector("span.user-dropdown__name")
    end
  end

  def click_google_login(user)
    credential = OmniAuth::AuthHash.new({
      :provider => :google_oauth2,
      :uid     => "1234",
      :info =>  {
                :email => user.email,
                :name => [user.first_name,user.last_name].join(' '),
                :image => "http://foo_image"
                },
      :extra => {
                :raw_info =>  {
                              :hd => "company"
                              }
                }
    })

    set_omniauth(credential)

    @modal.find(".modal-sign__col._sign-in .m-social__item.google a[href='/users/auth/google_oauth2']").click
  end
end
