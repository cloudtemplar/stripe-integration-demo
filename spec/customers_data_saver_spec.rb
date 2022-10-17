# frozen_string_literal: true

require 'customers_data_saver'

# rubocop:disable Metrics/BlockLength
describe CustomersDataSaver do
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

  describe '#save_customers_data' do
    subject(:save_customers_data) { described_class.new.save_customers_data(file_path: expected_file_path, payload: payload) }

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
  end

  describe '#last_saved_customer_id' do
    subject(:last_saved_customer_id) { described_class.new.last_saved_customer_id(file_path: expected_file_path) }

    context 'when file exists' do
      before do
        described_class.new.save_customers_data(file_path: expected_file_path, payload: payload)
      end

      it 'returns id of last saved customer' do
        expect(subject).to eq '1-foo-bar'
      end
    end

    context 'when file does not exist' do
      it 'returns nil' do
        expect(subject).to be_nil
      end
    end

    context 'when file has only headers' do
      before do
        described_class.new.save_customers_data(file_path: expected_file_path, payload: payload)
      end

      let(:payload) { [] }

      it 'returns nil' do
        expect(subject).to be_nil
      end
    end
  end

  after do
    File.delete(expected_file_path) if File.exist?(expected_file_path)
  end
end
# rubocop:enable Metrics/BlockLength
