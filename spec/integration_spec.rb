# frozen_string_literal: true

require 'vcr'
require 'support/vcr'
require 'customers_data_downloader'

describe 'Integration test' do
  subject(:download_customers_data) { CustomersDataDownloader.new.download_customers_csv_data(file_name: file_name) }

  let(:file_name) { 'customers' }
  let(:expected_file_path) { File.expand_path("../downloads/#{file_name}.csv", __dir__) }
  let(:expected_headers) { %w[id email name account_balance currency] }
  let(:expected_customer_info) { ['cus_FV1PwVVnBq065m', 'customer@example.com', 'John Smith', '0', 'usd'] }

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
