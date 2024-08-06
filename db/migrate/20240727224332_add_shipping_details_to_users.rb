class AddShippingDetailsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :state, :string unless column_exists?(:users, :state)
    add_column :users, :zip_code, :string unless column_exists?(:users, :zip_code)
    add_column :users, :country, :string unless column_exists?(:users, :country)
  end
end
