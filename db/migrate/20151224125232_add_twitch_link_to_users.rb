class AddTwitchLinkToUsers < ActiveRecord::Migration
  def change
    add_column :users, :twitch_link, :text
  end
end
