# frozen_string_literal: true

require 'stripe'

class StripeClient
  def initialize
    Stripe.api_key = ENV['STRIPE_API_KEY']
  end

  # I store customers in a single array because there are only 599 results.
  # I am aware that for bigger volume it could be inefficient, but even AR's ::find_each default batch is 1000.
  # If I was expecting more, I would use manual pagination and serialize results to CSV in parts.
  def fetch_customers_data
    payload = []
    customers = Stripe::Customer.list(limit: 50)
    customers.auto_paging_each do |customer|
      payload << customer
    end
    payload
  end
end
