class SignatureVerificationError < Stripe::StripeError
  attr_accessor :sig_header

  def initialize(message, sig_header, http_body: nil)
    super(message, http_body: http_body)
    @sig_header = sig_header
  end
end