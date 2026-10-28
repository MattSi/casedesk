class Firm < ApplicationRecord
    has_many :users, dependent: :restrict_with_error
    validates :name, presence: true, length: { maximum: 100 }
    validates :time_zone, inclusion: { in: ActiveSupport::TimeZone.all.map(&:name) }

    def now
        Time.current.in_time_zone(time_zone)
    end
end
