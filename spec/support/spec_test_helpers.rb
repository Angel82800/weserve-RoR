module SpecTestHelpers
 	def wait_for_ajax
 		Timeout.timeout(Capybara.default_max_wait_time) do
    	loop until finished_all_ajax_requests?
    end
  end
  
  def finished_all_ajax_requests?
    page.evaluate_script('jQuery.active').zero?
  end

  def set_omniauth(credentials)
    provider = credentials.provider

    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[provider] = credentials
    
    PictureUploader.any_instance.stub(:download!)
  end

  def fill_sign_up_form(form, user, options={})
    fields = %w(username email password password_confirmation)

    if options[:except].present?
      raise 'Except param must be an Array' unless options[:except].is_a?(Array)
      fields -= options[:except]
    end

    fields.each do |field|
      form.fill_in "user_#{field}", with: user.send(field)
    end
  end

  def submit_sign_up_form(form, user, options={})
    fill_sign_up_form(form, user, options)

    yield form if block_given?

    form.click_button 'Sign up'
    wait_for_ajax
  end
end

RSpec.configure do |config|
  config.include SpecTestHelpers, type: :feature
end