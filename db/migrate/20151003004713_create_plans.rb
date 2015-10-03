class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.references :project, index: true, null: false
      t.integer :amount, null: false
      t.integer :days, null: false
      t.integer :gateway_id, foreign_key: false
      t.text :name
      t.text :description

      t.timestamps
    end
  end
end
