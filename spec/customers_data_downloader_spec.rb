# frozen_string_literal: true

require 'customers_data_downloader'
require 'stripe_client'

describe CustomersDataDownloader do
  describe '#download_customers_csv_data' do
    subject(:download_customers_csv_data) { described_class.new.download_customers_csv_data(file_path: file_path) }

    let(:file_path) { 'file.csv' }
    let(:stripe_client_instance) { instance_double(StripeClient) }

    before do
      allow(StripeClient).to receive(:new).and_return(stripe_client_instance)
      allow(stripe_client_instance).to receive(:fetch_customers_data)
    end

    it 'fetches customers data from StripeClient' do
      download_customers_csv_data
      expect(stripe_client_instance).to have_received(:fetch_customers_data)
    end

    it { is_expected.to be true }
  end
end
