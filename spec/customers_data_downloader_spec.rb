# frozen_string_literal: true

require 'customers_data_downloader'
require 'stripe_client'
require 'customers_data_saver'

# rubocop:disable Metrics/BlockLength
describe CustomersDataDownloader do
  describe '#download_customers_csv_data' do
    subject(:download_customers_csv_data) do
      described_class
        .new(file_name: file_name, stripe_client: stripe_client_instance, customers_data_saver: data_saver_instance)
        .download_customers_csv_data
    end

    let(:file_name) { 'file' }
    let(:file_path) { File.expand_path("../downloads/#{file_name}.csv", __dir__) }
    let(:stripe_client_instance) { instance_double(StripeClient) }
    let(:data_saver_instance) { instance_double(CustomersDataSaver) }
    let(:customers_data_payload) do
      [
        {
          id: '0-john-doe',
          email: 'john.doe@example.com',
          name: 'John Doe',
          account_balance: 2137,
          currency: 'pln'
        }
      ]
    end

    before do
      allow(stripe_client_instance).to receive(:fetch_customers_data).and_return(customers_data_payload)
      allow(data_saver_instance).to receive(:last_saved_customer_id)
      allow(data_saver_instance)
        .to receive(:save_customers_data)
        .with(payload: customers_data_payload, file_path: file_path)
        .and_return(file_path)
    end

    it 'fetches id of last saved customer' do
      download_customers_csv_data
      expect(data_saver_instance).to have_received(:last_saved_customer_id).with(file_path: file_path)
    end

    it 'fetches customers data from StripeClient' do
      download_customers_csv_data
      expect(stripe_client_instance).to have_received(:fetch_customers_data)
    end

    it 'tells CustomersDataSaver to save customers data on given location' do
      download_customers_csv_data
      expect(data_saver_instance)
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
