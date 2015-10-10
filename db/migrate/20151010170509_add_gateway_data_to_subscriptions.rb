class AddGatewayDataToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :gateway_data, :json
  end
end
