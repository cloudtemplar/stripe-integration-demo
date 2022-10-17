# frozen_string_literal: true

require_relative 'stripe_client'
require_relative 'customers_data_saver'

class CustomersDataDownloader
  def initialize(stripe_client: ::StripeClient.new, customers_data_saver: ::CustomersDataSaver.new)
    @stripe_client = stripe_client
    @customers_data_saver = customers_data_saver
  end

  def download_customers_csv_data(file_name:)
    payload = stripe_client.fetch_customers_data
    customers_data_saver.save_customers_data(file_name: file_name, payload: payload)
  end

  private

  attr_reader :stripe_client, :customers_data_saver
end
