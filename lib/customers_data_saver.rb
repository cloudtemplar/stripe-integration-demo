# frozen_string_literal: true

require 'csv'

class CustomersDataSaver
  CSV_HEADERS = %i[id email name account_balance currency].freeze

  def save_customers_data(file_name:, payload:)
    file_path = File.expand_path("../downloads/#{file_name}.csv", __dir__)
    CSV.open(file_path, 'w') do |csv|
      csv << CSV_HEADERS
      payload.each do |p|
        csv << p.to_h.values_at(*CSV_HEADERS)
      end
    end
    file_path
  end
end
