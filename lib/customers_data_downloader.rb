# frozen_string_literal: true

class CustomersDataDownloader
  def download_customers_csv_data(file_path:)
    StripeClient.new.fetch_customers_data
    true
  end
end
