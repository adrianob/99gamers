class AddGatewayFeeToSubscriptions < ActiveRecord::Migration
  def change
    add_column(:subscriptions, :gateway_fee, :numeric)
  end
end
