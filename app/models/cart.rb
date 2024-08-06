class Cart < ApplicationRecord
  belongs_to :user, optional: true
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items
  has_one :order, dependent: :destroy

  validates :status, presence: true, inclusion: { in: ['pending', 'complete'] }
  validates :secret_id, presence: true, uniqueness: true

  before_create :set_secret_id

  enum status: { pending: 0, complete: 1 }

  private

  def set_secret_id
    self.secret_id = SecureRandom.uuid + DateTime.now.to_i.to_s
  end
end

