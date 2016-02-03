class CreateProjectTransfers < ActiveRecord::Migration
  def change
    create_table :project_transfers do |t|
      t.references :project
      t.text :state
      t.integer :amount

      t.timestamps
    end
  end
end
