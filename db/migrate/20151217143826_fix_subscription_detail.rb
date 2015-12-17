class FixSubscriptionDetail < ActiveRecord::Migration
  def change
    execute "DROP VIEW subscription_details;"
    execute "
    create or replace view subscription_details AS
     SELECT s.id,
      s.user_id as user_id,
      pl.id as plan_id,
      pl.amount AS value,
      s.state,
      p.id AS project_id,
      false AS anonymous,
      s.created_at
     FROM projects p
       JOIN plans pl ON pl.project_id = p.id
       JOIN subscriptions s ON s.plan_id = pl.id
       JOIN users u ON s.user_id = u.id; 
    "
  end
end
