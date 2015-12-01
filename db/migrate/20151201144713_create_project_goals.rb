class CreateProjectGoals < ActiveRecord::Migration
  def change
    create_table :goals do |t|
      t.references :project, index: true, null: false
      t.text :title, null: false
      t.integer :value, null: false
      t.text :description

      t.timestamps
    end
  end
end
