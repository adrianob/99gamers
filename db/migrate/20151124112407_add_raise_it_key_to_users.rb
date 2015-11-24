class AddRaiseItKeyToUsers < ActiveRecord::Migration
  def change
    add_column :users, :raiseit_key, :text
    add_column :users, :raiseit_id, :text, foreign_key: false
  end
end
