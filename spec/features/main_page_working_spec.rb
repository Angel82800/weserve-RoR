require 'rails_helper'

feature 'Home page working or not  ', :js => true do
  before do
    setup_spec if respond_to?(:setup_spec)
    visit '/'
  end

  shared_examples "changing the locale" do
    before do
      find('div.s-header__lang-select').click
      @modal = find('div#changeLanguageModal', visible: true)
    end

    scenario "Then language selection modal appeared" do
      expect(@modal).to be_visible
    end

    context 'and you selected French' do
      before do
        find('.modal-change-language__name', :text => 'French').click
      end

      scenario "Then the page is translated to french" do
        expect(page).to have_content I18n.t('commons.start_a_project', locale: 'fr')
      end

      context 'and you again clicked the flag' do
        before do
          find('div.s-header__lang-select').click
          @modal = find('div#changeLanguageModal', visible: true)
        end

        context 'and you selected English' do
          before do
            find('.modal-change-language__name', :text => 'English').click
          end

          scenario "Then the page is translated back to english" do
            expect(page).to have_content I18n.t('commons.start_a_project', locale: 'en')
          end
        end
      end
    end
  end

  shared_examples "working page" do
    scenario 'Website is working' do
      page.status_code == '200'
    end
  end


  context "when anonymous user visits" do
    it_behaves_like "changing the locale"
    it_behaves_like "working page"

    scenario 'login and register options are visible' do
      expect(page).to have_text( I18n.t 'commons.login' )
      expect(page).to have_text( I18n.t 'commons.register' )
    end

    context "and user is from france" do
      let(:setup_spec) do
        allow_any_instance_of(ApplicationController).to receive(:location_detected_locale).and_return('fr')
      end
      it "loads french version" do
        expect(page).to have_current_path("/?locale=fr")
      end
    end
  end


  context "when user is logged in" do
    let(:user) {create(:user, :confirmed_user, preferred_language: preferred_language)}
    let(:preferred_language) { 'en' }
    let(:setup_spec) { login_as(user) }


    it_behaves_like "changing the locale"
    it_behaves_like "working page"

    context "and user's preferred locale is engi" do
      context "and user is logging from france" do
        let(:setup_spec) do
          allow_any_instance_of(ApplicationController).to receive(:location_detected_locale).and_return('fr')
          login_as(user)
        end
        it "loads english version" do
          expect(page).to have_content I18n.t('commons.start_a_project', locale: 'en')
        end
      end
    end
  end
end

