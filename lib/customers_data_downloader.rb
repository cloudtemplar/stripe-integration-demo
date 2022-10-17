# frozen_string_literal: true

require_relative 'stripe_client'
require_relative 'customers_data_saver'

class CustomersDataDownloader
  def initialize(file_name:, file_path: nil, stripe_client: ::StripeClient.new, customers_data_saver: ::CustomersDataSaver.new)
    @stripe_client = stripe_client
    @customers_data_saver = customers_data_saver
    @file_path = file_path || calculate_file_path(file_name)
  end

  def download_customers_csv_data
    last_saved_customer_id = customers_data_saver.last_saved_customer_id(file_path: file_path)
    payload = stripe_client.fetch_customers_data(download_data_after: last_saved_customer_id)
    customers_data_saver.save_customers_data(file_path: file_path, payload: payload)
  end

  private

  attr_reader :stripe_client, :customers_data_saver, :file_path

  def calculate_file_path(file_name)
    File.expand_path("../downloads/#{file_name}.csv", __dir__)
  end
end
