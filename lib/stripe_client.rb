# frozen_string_literal: true

require 'stripe'
require 'pry'

class StripeClient
  def initialize
    Stripe.api_key = ENV['STRIPE_API_KEY']
  end

  def fetch_customers_data
    Stripe::Customer.list.data
  end
end
