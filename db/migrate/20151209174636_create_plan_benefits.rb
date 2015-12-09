class CreatePlanBenefits < ActiveRecord::Migration
  def change
    create_table :plan_benefits do |t|
      t.references :plan
      t.text :description

      t.timestamps
    end
  end
end
