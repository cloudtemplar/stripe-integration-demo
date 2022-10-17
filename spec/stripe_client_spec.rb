# frozen_string_literal: true

require 'stripe_client'
require 'vcr'
require 'support/vcr'

describe StripeClient do
  describe '#fetch_customers_data' do
    subject(:fetch_customers_data) { described_class.new.fetch_customers_data }

    let(:expected_payload) do
      {
        id: 'cus_MZLaaJi3ck3Cdz',
        email: nil,
        name: 'unprorated - prorated change',
        account_balance: 0,
        currency: 'usd'
      }
    end

    before do
      VCR.insert_cassette 'stripe/customers'
    end

    it 'fetches customers data' do
      payload = fetch_customers_data[0].to_h.slice(:id, :email, :name, :account_balance, :currency)
      expect(payload).to eq expected_payload
    end

    after do
      VCR.eject_cassette 'stripe/customers'
    end
  end
end
