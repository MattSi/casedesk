class Contact < ApplicationRecord
  belongs_to :firm
  has_many :matters, foreign_key: :client_id, inverse_of: :client, dependent: :restrict_with_error

  normalizes :email, with: ->(e) { e.strip.downcase }

  validates :name, presence: true
end
