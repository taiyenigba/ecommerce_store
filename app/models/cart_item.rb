class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  validates :cart_id, presence: true
  validates :product_id, presence: true
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }

  before_create :set_default_quantity

  private

  def set_default_quantity
    self.quantity ||= 1
  end
end

