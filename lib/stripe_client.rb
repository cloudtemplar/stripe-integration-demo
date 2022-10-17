# frozen_string_literal: true

require 'stripe'

class StripeClient
  class TimeoutError < StandardError; end

  MAX_RETRIES = 5

  def initialize
    Stripe.api_key = ENV['STRIPE_API_KEY']
  end

  # I store customers in a single array because there are only 599 results.
  # I am aware that for bigger volume it could be inefficient, but even AR's ::find_each default batch is 1000.
  # If I was expecting more, I would use manual pagination and serialize results to CSV in parts.
  def fetch_customers_data
    payload = []
    retries = 0
    begin
      customers = Stripe::Customer.list(limit: 50)
      customers.auto_paging_each do |customer|
        payload << customer
      end
    rescue Stripe::RateLimitError => e
      if retries < MAX_RETRIES
        sleep_seconds = 2**retries + Float(rand(1..1000)) / 1000
        retries += 1
        sleep sleep_seconds
        payload = []
        retry
      else
        raise StripeClient::TimeoutError, "Timeout: #{e.message}"
      end
    end
    payload
  end
end
