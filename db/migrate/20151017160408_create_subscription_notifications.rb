class CreateSubscriptionNotifications < ActiveRecord::Migration
  def change
    add_column :subscriptions, :gateway_id, :integer, foreign_key: false
    create_table :subscription_notifications do |t|
      t.text :extra_data
      t.references :subscription, index: true

      t.timestamps
    end
  end
end
