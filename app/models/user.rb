class User < ApplicationRecord
  has_secure_password
  belongs_to :firm
  has_many :sessions, dependent: :destroy
  has_many :assigned_tasks, class_name: "Task", foreign_key: :assignee_id, inverse_of: :assignee, dependent: :restrict_with_error

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :name, presence: true
  validates :email_address, presence: true, uniqueness: true
end
