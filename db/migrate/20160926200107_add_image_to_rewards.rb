class AddImageToRewards < ActiveRecord::Migration
  def change
    add_column :rewards, :uploaded_image, :text
  end
end
