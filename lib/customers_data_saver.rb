# frozen_string_literal: true

require 'csv'

class CustomersDataSaver
  CSV_HEADERS = %i[id email name account_balance currency].freeze

  def save_customers_data(file_path:, payload:)
    insert_headers(file_path) unless File.exist?(file_path)

    CSV.open(file_path, 'ab') do |csv|
      payload.each do |p|
        csv << p.to_h.values_at(*CSV_HEADERS)
      end
    end
    file_path
  end

  def last_saved_customer_id(file_path:)
    return nil unless File.exist?(file_path)

    last_row = CSV.read(file_path).last
    return nil if last_row == CSV_HEADERS.map(&:to_s)

    last_row[0]
  end

  private

  def insert_headers(file_path)
    CSV.open(file_path, 'w') { |csv| csv << CSV_HEADERS }
  end
end
