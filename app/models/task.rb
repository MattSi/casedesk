class Task < ApplicationRecord
  belongs_to :firm
  belongs_to :matter
  belongs_to :assignee, class_name: "User"

  enum :status, { open: "open", completed: "completed" }, validate: true

  before_validation :copy_firm_from_matter

  validates :title, presence: true
  validate :matter_and_assignee_in_same_firm

  scope :overdue, ->(now = Time.current) { open.where(due_at: ...now) }
  scope :due_between, ->(range) { open.where(due_at: range) }

  def complete!
    update!(status: :completed, completed_at: Time.current)
  end

  def overdue?(now = Time.current)
    open? && due_at.present? && due_at < now
  end

  # Whole days past the due date, e.g. 2 for "2d overdue"
  def days_overdue(now = Time.current)
    return 0 unless overdue?(now)
    ((now - due_at) / 1.day).floor
  end

  private
    def copy_firm_from_matter
      self.firm ||= matter&.firm
    end

    def matter_and_assignee_in_same_firm
      errors.add(:matter, "must belong to the same firm") if matter && matter.firm_id != firm_id
      errors.add(:assignee, "must belong to the same firm") if assignee && assignee.firm_id != firm_id
    end
end
