# frozen_string_literal: true

require 'customers_data_downloader'
require 'stripe_client'
require 'customers_data_saver'

# rubocop:disable Metrics/BlockLength
describe CustomersDataDownloader do
  describe '#download_customers_csv_data' do
    subject(:download_customers_csv_data) { described_class.new.download_customers_csv_data(file_path: file_path) }

    let(:file_path) { '/path/to/file.csv' }
    let(:stripe_client_instance) { instance_double(StripeClient) }
    let(:customers_data_saver_instance) { instance_double(CustomersDataSaver) }
    let(:customers_data_payload) do
      {
        data: true
      }
    end

    before do
      allow(StripeClient).to receive(:new).and_return(stripe_client_instance)
      allow(CustomersDataSaver).to receive(:new).and_return(customers_data_saver_instance)
      allow(stripe_client_instance).to receive(:fetch_customers_data).and_return(customers_data_payload)
      allow(customers_data_saver_instance)
        .to receive(:save_customers_data)
        .with(payload: customers_data_payload, file_path: file_path)
        .and_return(file_path)
    end

    it 'fetches customers data from StripeClient' do
      download_customers_csv_data
      expect(stripe_client_instance).to have_received(:fetch_customers_data)
    end

    it 'tells CustomersDataSaver to save customers data on given location' do
      download_customers_csv_data
      expect(customers_data_saver_instance)
        .to have_received(:save_customers_data)
        .with(payload: customers_data_payload,
              file_path: file_path)
    end

    it 'returns location of newly created file' do
      expect(download_customers_csv_data).to eq file_path
    end
  end
end
# rubocop:enable Metrics/BlockLength
