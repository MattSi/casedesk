class Matter < ApplicationRecord
  belongs_to :firm
  belongs_to :client, class_name: "Contact"

  has_many :tasks, dependent: :destroy
  has_many :calendar_events, dependent: :nullify

  enum :status, { open: "open", pending: "pending", closed: "closed" }, validate: true

  before_validation :assign_number, on: :create

  validates :title, presence: true
  validates :number, presence: true, uniqueness: { scope: :firm_id }
  validate :client_in_same_firm

  # "00014-Harrington"
  def display_name
    "#{number}-#{client.name.split.last}"
  end

  private
    # Next number within the firm, zero-padded: 00001, 00002, ...
    def assign_number
      return if number.present? || firm.nil?
      last = firm.matters.maximum(:number).to_i
      self.number = format("%05d", last + 1)
    end

    def client_in_same_firm
      if client && firm && client.firm_id != firm_id
        errors.add(:client, "must belong to the same firm")
      end
    end
end
