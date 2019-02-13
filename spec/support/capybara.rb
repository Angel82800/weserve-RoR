require 'capybara/rspec'
require 'capybara/rails'
require 'capybara/poltergeist'
#require 'capybara-screenshot/rspec'
#require 'selenium/webdriver'

=begin
chrome_bin = ENV.fetch('GOOGLE_CHROME_SHIM', nil)

chrome_opts = chrome_bin ? {
    "chromeOptions" => {
        "binary" => chrome_bin
    }
} : {}

Capybara.register_driver :chrome do |app|

  client = Selenium::WebDriver::Remote::Http::Default.new
  client.read_timeout = 120

  Capybara::Selenium::Driver.new(
      app,
      browser: :chrome,
      http_client: client,
      desired_capabilities: Selenium::WebDriver::Remote::Capabilities.chrome(chrome_opts)
  )
end

Capybara::Screenshot.register_driver(:chrome) do |driver, path|
  driver.browser.save_screenshot(path)
end

Capybara.javascript_driver = :chrome
=end

Capybara.register_driver :poltergeist do |app|

  options = {
      :window_size => [1600, 900],
      :screen_size => [1600, 900],
      :timeout => 180,
      js_errors: false,
      phantomjs_options: %w(--ignore-ssl-errors=yes --ssl-protocol=any)
  }

  Capybara::Poltergeist::Driver.new(app, options)
end

Capybara.javascript_driver = :poltergeist
Capybara.ignore_hidden_elements = false
Capybara.server_port = 35792
Capybara.default_max_wait_time = 10

RSpec.configure do |c|
  c.silence_filter_announcements = true
  c.include Capybara::DSL
  c.include(Module.new do
    def click_pseudo_link(text)
      first('a', text: text).click
    end
  end)
end
