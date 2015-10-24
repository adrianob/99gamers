class JsonNotification < ActiveRecord::Migration
  def change
    execute "
    ALTER TABLE subscription_notifications ALTER COLUMN extra_data TYPE JSON USING extra_data::JSON;
    "
    execute "
    ALTER TABLE ONLY plans ALTER COLUMN enabled SET DEFAULT true;
    "
  end
end
