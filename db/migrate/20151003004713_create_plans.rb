class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.references :project, index: true, null: false
      t.integer :amount, null: false
      t.integer :days, null: false
      t.integer :installments, null: false

      t.timestamps
    end
  end
end
