class AddCoverImageToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :cover_image, :text
  end
end
