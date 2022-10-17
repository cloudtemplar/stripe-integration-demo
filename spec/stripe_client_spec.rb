# frozen_string_literal: true

require 'stripe_client'
require 'vcr'
require 'support/vcr'

describe StripeClient do
  describe '#fetch_customers_data' do
    subject(:fetch_customers_data) { described_class.new.fetch_customers_data }

    let(:expected_payload) do
      {
        id: 'cus_FV1PwVVnBq065m',
        email: 'customer@example.com',
        name: 'John Smith',
        account_balance: 0,
        currency: 'usd'
      }
    end

    before do
      VCR.insert_cassette 'stripe/customers'
    end

    context 'when there are no errors' do
      it 'fetches customers data' do
        payload = fetch_customers_data.last.to_h.slice(:id, :email, :name, :account_balance, :currency)
        expect(payload).to eq expected_payload
      end
    end

    context 'when occuring Stripe::RateLimitError' do
      before do
        StripeClient::MAX_RETRIES = 1
        allow(Stripe::Customer).to receive(:list).and_raise(Stripe::RateLimitError)
      end

      it 'retries for a given amount of times' do
        expect(Stripe::Customer).to receive(:list).twice
        fetch_customers_data
      rescue StripeClient::TimeoutError
      end

      it 'raises StripeClient::TimeoutError after retrying' do
        expect { fetch_customers_data }.to raise_error(StripeClient::TimeoutError)
      end
    end

    after do
      VCR.eject_cassette 'stripe/customers'
    end
  end
end
