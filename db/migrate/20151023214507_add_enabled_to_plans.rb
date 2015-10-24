class AddEnabledToPlans < ActiveRecord::Migration
  def change
    add_column(:plans, :enabled, :boolean)
  end
end
