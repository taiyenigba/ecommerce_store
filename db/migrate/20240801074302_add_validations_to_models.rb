class AddValidationsToModels < ActiveRecord::Migration[7.0]
  def change
    change_column_null :users, :email, false
    change_column_null :users, :username, false
    change_column_null :users, :address, false
    change_column_null :users, :city, false
    change_column_null :users, :state, false
    change_column_null :users, :zip_code, false
    change_column_null :users, :country, false
    change_column_null :users, :first_name, false
    change_column_null :users, :last_name, false

    change_column_null :products, :name, false
    change_column_null :products, :description, false
    change_column_null :products, :price, false

    change_column_null :categories, :name, false

    change_column_null :orders, :status, false
    change_column_null :orders, :total, false

    change_column_null :carts, :status, false
    change_column_null :carts, :secret_id, false
  end
end
