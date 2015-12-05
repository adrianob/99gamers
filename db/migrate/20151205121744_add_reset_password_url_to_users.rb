class AddResetPasswordUrlToUsers < ActiveRecord::Migration
  def change
    add_column :users, :reset_password_url, :text
  end
end
