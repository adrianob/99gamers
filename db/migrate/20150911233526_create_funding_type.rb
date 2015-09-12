class CreateFundingType < ActiveRecord::Migration
  def change
    create_table :funding_types do |t|
      t.text :name, null: false
    end
  end
end
