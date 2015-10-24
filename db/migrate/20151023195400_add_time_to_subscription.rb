class AddTimeToSubscription < ActiveRecord::Migration
  def change
    add_column :subscriptions, :canceled_at, :timestamp
    add_column :subscriptions, :paid_at, :timestamp
    add_column :subscriptions, :pending_payment_at, :timestamp
  end
end
