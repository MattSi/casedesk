class CalendarEvent < ApplicationRecord
  belongs_to :firm
  belongs_to :user
  belongs_to :matter, optional: true

  before_validation :copy_firm_from_user

  validates :title, :starts_at, :ends_at, presence: true
  validate :ends_after_start
  validate :matter_in_same_firm

  scope :starting_between, ->(range) { where(starts_at: range) }

  # Used to sort events and tasks together in Upcoming
  def scheduled_at
    starts_at
  end

  private
    def copy_firm_from_user
      self.firm ||= user&.firm
    end

    def ends_after_start
      if starts_at && ends_at && ends_at <= starts_at
        errors.add(:ends_at, "must be after the start time")
      end
    end

    def matter_in_same_firm
      errors.add(:matter, "must belong to the same firm") if matter && matter.firm_id != firm_id
    end
end
