class Product < ApplicationRecord
  has_rich_text :description
  has_many_attached :images
  belongs_to :category, optional: true
  has_many :cart_items

  validates :name, presence: true, uniqueness: true, length: { maximum: 100 }

  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :on_sale, -> { where(on_sale: true) }
  scope :new_products, -> { where('created_at >= ?', 3.days.ago) }
  scope :recently_updated, -> { where('updated_at >= ? AND created_at < ?', 3.days.ago, 3.days.ago) }

  before_validation :set_default_description

  # Plain text search method
  def self.search_by_keyword(keyword, category_id = nil)
    keyword = "%#{keyword}%"
    products = where('name LIKE ? OR description LIKE ?', keyword, keyword)
    products = products.where(category_id: category_id) if category_id.present?
    products
  end

  private

  def set_default_description
    self.description = "Default description" if description.blank?
  end
end
