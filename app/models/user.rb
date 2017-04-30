class User < ApplicationRecord
  # validates(:phone, presence: true)
  # validates(:phone, latitude: true)
  # validates(:phone, longitude: true)
  def self.to_csv
    attributes = %w{phone latitude longitude}

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |user|
        csv << attributes.map{ |attr| user.send(attr) }
      end
    end
  end


end
