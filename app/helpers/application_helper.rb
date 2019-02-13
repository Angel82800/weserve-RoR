require "currency_conversion"
module ApplicationHelper
  def gravatar_for_user(user, size = 30, title = user.display_name )
    image_tag t('commons.default_user_pic'), size: size.to_s + 'x' + size.to_s, title: title, class: 'img-rounded'
  end

  def gravatar_for_project(project, size = 440, title = project.title )
    image_tag gravatar_image_url(project.title, size: size), title: title, class: 'img-rounded'
  end

  def landing_page?
    controller.controller_name.eql?('visitors') && controller.action_name.eql?('landing')
  end

  def landing_class
    'class=landing' if landing_page?
  end

  def btc_balance(btc)
    btc.to_f.round(4)
  end

  def balance_in_usd(balance)
    CurrencyConversion.cents_to_usd(balance)
  end

  def format_currency(balance)
    number_with_precision(balance_in_usd(balance), :precision => 2)
  end

  def min_fund_budget_in_usd
    balance_in_usd(Task::MINIMUM_FUND_BUDGET)
  end

  def min_donation_size_in_usd
    balance_in_usd(Task::MINIMUM_DONATION_SIZE)
  end

  def min_transfer_amount_in_usd
    balance_in_usd(Payments::BTC::FundBtcAddress::MIN_AMOUNT)
  end

  def projects_taskstab?
    controller_name == 'projects' && action_name == 'taskstab'
  end

  def active_class(link_path)
   request.fullpath == link_path ? "active" : ""
  end

  def stripe_available_country
    YAML.load_file('config/stripe_available_country.yml')
  end

  def stripe_available_currency
    YAML.load_file('config/stripe_available_currency.yml')
  end

  def custom_acc_status
   case current_user.custom_account.status
    when 'unverified'
      content_tag :i, class: "fa fa-times-circle-o circle-check tooltips", style: "color: #E34429" do
        content_tag(:div, current_user.custom_account.status.capitalize, class: "unverified_cls") +
        link_to("Verify", verify_user_path) +
        content_tag(:span, t('commons.unverified'), class: "tooltiptext")
      end
    when 'pending'
      content_tag :i, class: "fa fa-exclamation-circle circle-check", style: "color: #1464F6" do
        current_user.custom_account.status.capitalize
      end
    when 'verified'
      content_tag :i, class: "fa fa-check-circle-o circle-check", style: "color: #629C44" do
        current_user.custom_account.status.capitalize
      end
   end
  end

  def needed_fields
    case current_user.payout_detail.country
      when "US"
        for_personal_id  +
        for_legal_document
      when "CA", "HK", "SG"
        for_personal_id  +
        for_legal_document
      when "AT","AU", "BE", "CH", "DE", "DK", "ES", "FI", "FR", "GB", "IE", "IT", "LU", "NL", "NO", "NZ", "PT", "SE"
        for_legal_document
    end
  end

  def for_personal_id
    content_tag(:div, class: "col-sm-12 col-xs-12") do
      content_tag(:div, class: "form-group") do
        content_tag(:label, "Personal Id Number") +
          text_field_tag('personal_id','', :class => 'form-control', required: true, type: "number")
      end
    end
  end

  def for_legal_document
    content_tag(:div, class: "col-sm-12 col-xs-12") do
      content_tag(:div, class: "form-group") do
        content_tag(:label, "Legal Document") +
          file_field_tag('legal_document',{:class => 'form-control', required: true })
      end
    end
  end

  def for_last_4_ssn
    content_tag(:div, class: "col-sm-12 col-xs-12") do
      content_tag(:div, class: "form-group") do
        content_tag(:label, "Last 4 digits of your SSN") +
          text_field_tag('last_4_ssn','', :class => 'form-control', placeholder: "1234",required: true, type: "number")
      end
    end
  end

  def nl2br text
    text.gsub('<br />', "\n")
  end

  def logo_link
    if ENV['logo_link'].present?
      ENV['logo_link']
    else
      root_path
    end
  end

  def tax_deduction_action_link
    current_user.tax_deduction.blank? ? new_tax_deduction_path : edit_tax_deduction_path(current_user.tax_deduction.id)
  end
end
