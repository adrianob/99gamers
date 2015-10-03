class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.references :plan, index: true, null: false
      t.references :user, index: true, null: false

      t.timestamps
    end
  end
end
