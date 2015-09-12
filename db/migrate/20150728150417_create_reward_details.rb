class CreateRewardDetails < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE OR REPLACE FUNCTION paid_count(rewards) RETURNS bigint AS $$
      SELECT count(*) 
      FROM payments p join contributions c on c.id = p.contribution_id 
      WHERE p.state = 'paid' AND c.reward_id = $1.id
    $$ LANGUAGE SQL STABLE SECURITY DEFINER;

    CREATE OR REPLACE FUNCTION waiting_payment_count(rewards) RETURNS bigint AS $$
      SELECT count(*) 
      FROM payments p join contributions c on c.id = p.contribution_id 
      WHERE p.waiting_payment AND c.reward_id = $1.id
    $$ LANGUAGE SQL STABLE SECURITY DEFINER;

    CREATE VIEW reward_details AS
    SELECT 
      r.id,
      r.description,
      r.minimum_value,
      r.maximum_contributions,
      r.deliver_at,
      r.updated_at,
      r.paid_count,
      r.waiting_payment_count
     FROM rewards r;
    SQL
  end

  def down
    execute <<-SQL
      DROP VIEW reward_details;
      DROP FUNCTION paid_count(rewards);
      DROP FUNCTION waiting_payment_count(rewards);
    SQL
  end
end
