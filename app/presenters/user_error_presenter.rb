# +UserErrorPresenter+ is responsible for presenting errors in user-friedly format.
#
# Error replacement is needed when we want to keep original exception to
# our internal error reporting, but want to replace original message because:
#
# * we want to hide real error cause from user and show a general message
# * we want to re-phrase the error message
class UserErrorPresenter
  attr_reader :error

  # Mapping of errors in the following format:
  #
  # "error_class1" => {
  #   "original message1" => "replacement for message1",
  #   "original message2" => "replacement for message2"
  # },
  # "error_class2" => {
  #   "original message3" => "replacement for message3",
  # }
  SUBSTITUTIONS = {
    "Payments::BTC::Errors::TransferError" => {
      "Not found" => "Not enough funds on the balance to perform this operation",
      "Please enter a valid email or Bitcoin address" => "Please enter a valid Bitcoin address"
    },
    "Payments::BTC::Errors::GeneralError" => {
      "Coinbase API error" => I18n.t('commons.connecting_payment_service_error')
    }
  }

  def initialize(error)
    @error = error
  end

  # Lookup for error message substitution.
  #
  # In case if matching substitution was not found then original message is
  # returned.
  def message
    substitution ? substitution : original_error_message
  end

  private
  def substitution
    klass = error.class.to_s

    if SUBSTITUTIONS[klass]
      SUBSTITUTIONS[klass][error.message]
    else
      return nil
    end
  end

  def original_error_message
    error.message
  end
end
