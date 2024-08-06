class Order < ApplicationRecord
  belongs_to :user
  belongs_to :cart

  enum status: { pending: 0, complete: 1 }

  validates :status, presence: true, inclusion: { in: ['pending', 'complete'] }
  validates :total, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
