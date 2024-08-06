class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.references :cart, null: false, foreign_key: true
      t.integer :status
      t.decimal :total

      t.timestamps
    end
  end
end
