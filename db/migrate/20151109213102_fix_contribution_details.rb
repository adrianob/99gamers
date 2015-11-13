class FixContributionDetails < ActiveRecord::Migration
  def change
    execute <<-SQL
    CREATE OR REPLACE VIEW subscription_details as
SELECT 
  s.id,
  s.user_id,
  pl.amount as value,
  s.state,
  p.id as project_id,
  false as anonymous,
  s.created_at
   FROM projects p
      JOIN plans pl on pl.project_id = p.id
      JOIN subscriptions s on s.plan_id = pl.id
       JOIN users u ON s.user_id = u.id;

    SQL
  end
end
