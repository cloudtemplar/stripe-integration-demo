# frozen_string_literal: true

class CustomersDataDownloader
  def download_customers_csv_data(file_path:)
    payload = StripeClient.new.fetch_customers_data
    CustomersDataSaver.new.save_customers_data(payload: payload, file_path: file_path)
  end
end
