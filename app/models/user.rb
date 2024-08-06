class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :orders, dependent: :destroy
  has_many :carts, dependent: :destroy

  # Validations
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :username, presence: true, uniqueness: true, length: { in: 3..20 }
  validates :address, presence: true
  validates :city, presence: true
  validates :state, presence: true
  validates :zip_code, presence: true, length: { in: 5..10 }
  validates :country, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true

  def full_name
    "#{first_name} #{last_name}"
  end
end
