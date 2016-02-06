class AlterTransferAmount < ActiveRecord::Migration
  def change
    change_column :project_transfers, :amount,  :numeric
  end
end
