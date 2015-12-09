class CreateRewardBenefits < ActiveRecord::Migration
  def change
    create_table :reward_benefits do |t|
      t.references :reward
      t.text :description

      t.timestamps
    end
  end
end
