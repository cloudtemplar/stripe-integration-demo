# frozen_string_literal: true

require 'customers_data_saver'

# rubocop:disable Metrics/BlockLength
describe CustomersDataSaver do
  describe '#save_customers_data' do
    subject(:save_customers_data) { described_class.new.save_customers_data(file_name: file_name, payload: payload) }

    let(:file_name) { 'customers_data_1' }
    let(:payload) do
      [
        {
          id: '0-john-doe',
          email: 'john.doe@example.com',
          name: 'John Doe',
          account_balance: 2137,
          currency: 'pln'
        },
        {
          id: '1-foo-bar',
          email: 'foo.bar@example.com',
          name: 'Foo Bar',
          account_balance: 1111,
          currency: 'usd'
        }
      ]
    end
    let(:expected_file_path) { File.expand_path("../downloads/#{file_name}.csv", __dir__) }
    let(:serialized_payload) do
      [['id', 'email', 'name', 'account_balance', 'currency'],
       ['0-john-doe', 'john.doe@example.com', 'John Doe', '2137', 'pln'],
       ['1-foo-bar', 'foo.bar@example.com', 'Foo Bar', '1111', 'usd']]
    end

    it 'returns path of created file' do
      expect(save_customers_data).to eq expected_file_path
    end

    it 'correctly serializes payload to csv' do
      save_customers_data
      customers_data = CSV.read(expected_file_path)
      expect(customers_data).to eq serialized_payload
    end

    after do
      File.delete(expected_file_path) if File.exist?(expected_file_path)
    end
  end
end
# rubocop:enable Metrics/BlockLength
