class AddBackgroundImageToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :background_image, :text
  end
end
