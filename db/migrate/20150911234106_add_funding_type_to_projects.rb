class AddFundingTypeToProjects < ActiveRecord::Migration
  def change
    add_reference :projects, :funding_type, index: true, null: false
  end
end
