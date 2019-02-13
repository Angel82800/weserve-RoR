require 'rails_helper'

feature 'Twitter login', js: true do
  before do
    visit '/'
    find(".auth_links .sign_in_a").trigger("click")

    @modal = find('div#registerModal', visible: true)
  end

  let(:uid) { "1234" }

  scenario "Sign in popup appeared when click login link" do
    expect(@modal).to be_visible
  end

  context "as already registered user" do
    before do
      @user = FactoryGirl.create(:user, email: uid + "@twitter.com", confirmed_at: Time.now)

      click_twitter_login(@user)
    end

    scenario "log in with the user's twitter account" do
      expect(page).to have_selector("span.user-dropdown__name")
    end
  end

  context "as new user" do
    before(:each) do
      @user = FactoryGirl.build(:user, :email => uid + "@twitter.com")

      @before_count = User.count

      click_twitter_login(@user)
    end

    scenario "registered with the user's twitter account" do
      expect(User.count).not_to eq @before_count
    end

    scenario "log in with the user's twitter account" do
      expect(page).to have_selector("span.user-dropdown__name")
    end
  end

  def click_twitter_login(user)
    credential = OmniAuth::AuthHash.new({
      :provider => :twitter,
      :uid     => uid,
      :info =>  {
                :email => user.email,
                :name => [user.first_name,user.last_name].join(' '),
                :image => "http://foo_image",
                :description => "description",
                :location => "Germany",
                :urls =>  {
                            :Twitter => "twitter_url"
                          }
                }
    })

    set_omniauth(credential)

    @modal.find(".modal-sign__col._sign-in .m-social__item.twitter a[href='/users/auth/twitter']").click
  end
end
