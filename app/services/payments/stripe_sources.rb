class Payments::StripeSources
  def call(user:)
    stripe_customer_id = user.stripe_customer_id
    return [] if stripe_customer_id.blank?

    customer = Stripe::Customer.retrieve(stripe_customer_id)
    customer.sources.map do |source|
      {
        id: source.id,
        last4: source[:card].last4
      }
    end
  end
end
