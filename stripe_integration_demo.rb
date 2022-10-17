# frozen_string_literal: true

require_relative 'lib/customers_data_downloader'

CustomersDataDownloader.new(file_name: 'example_stripe_download').download_customers_csv_data
