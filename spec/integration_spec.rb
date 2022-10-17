# frozen_string_literal: true

require 'vcr'
require 'support/vcr'
require 'customers_data_downloader'

describe 'Integration test' do
  subject(:download_customers_data) { CustomersDataDownloader.new(file_name: file_name).download_customers_csv_data }

  let(:file_name) { 'customers' }
  let(:expected_file_path) { File.expand_path("../downloads/#{file_name}.csv", __dir__) }
  let(:expected_headers) { %w[id email name account_balance currency] }
  let(:expected_customer_info) { ['cus_FV1PwVVnBq065m', 'customer@example.com', 'John Smith', '0', 'usd'] }

  context 'when storing new results in empty file' do
    before do
      VCR.insert_cassette 'stripe/customers'
    end

    it 'downloads customers info and saves it into CSV file' do
      download_customers_data
      customers_data = CSV.read(expected_file_path)
      expect(customers_data[0]).to eq expected_headers
      expect(customers_data.last).to eq expected_customer_info
    end

    it 'returns path of newly created file' do
      expect(download_customers_data).to eq expected_file_path
    end

    after do
      VCR.eject_cassette 'stripe/customers'
      File.delete(expected_file_path) if File.exist?(expected_file_path)
    end
  end

  context 'when continuing after saving only partial results' do
    subject(:download_customers_data) do
      CustomersDataDownloader.new(
        file_name: 'partial_results',
        file_path: partial_results_csv_copy_path
      ).download_customers_csv_data
    end

    let(:partial_results_csv_path) { File.expand_path('../spec/fixtures/partial_results.csv', __dir__) }
    let(:partial_results_csv_copy_path) { File.expand_path('../spec/fixtures/partial_results_copy.csv', __dir__) }

    before do
      VCR.insert_cassette 'stripe/partial_results'
      FileUtils.cp(partial_results_csv_path, partial_results_csv_copy_path)
    end

    # Before:
    # first row in fixtures => cus_H3LredgKHAL0Le,miley@example.com,miley cyrus,0,usd
    # last row in fixtures => cus_GNnjagaqzo1cJA,eliza@customer.com,eliza johnson,0,usd
    #
    # After:
    # first row in fixtures => cus_H3LredgKHAL0Le,miley@example.com,miley cyrus,0,usd
    # last row in fixtures => cus_FV1PwVVnBq065m,customer@example.com,John Smith,0,usd
    #
    # Comment out deleting the copy of partial results to see it working

    it 'appends the rest of results to existing CSV' do
      download_customers_data
      customers_data = CSV.read(partial_results_csv_copy_path)
      expect(customers_data.last).to eq expected_customer_info
    end

    after do
      VCR.eject_cassette 'stripe/partial_results'
      File.delete(partial_results_csv_copy_path) if File.exist?(partial_results_csv_copy_path)
    end
  end
end
