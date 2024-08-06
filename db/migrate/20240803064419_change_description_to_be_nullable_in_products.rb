class ChangeDescriptionToBeNullableInProducts < ActiveRecord::Migration[7.1]
  def change
    change_column_null :products, :description, true
  end
end
