class FixUserTotals < ActiveRecord::Migration
  def change
    execute "
    DROP MATERIALIZED VIEW user_totals;"
    execute"
    CREATE MATERIALIZED VIEW user_totals AS
    SELECT b.user_id AS id,
    b.user_id,
    count(DISTINCT p.id) AS total_contributed_projects,
    sum(pa.value) AS sum,
    count(DISTINCT b.id) AS count,
    0 as credits
   FROM users u
     LEFT JOIN contributions b ON b.user_id = u.id
     LEFT JOIN payments pa ON b.id = pa.contribution_id
     LEFT JOIN subscriptions sb ON sb.user_id = u.id
     LEFT JOIN plans pl ON pl.id = sb.plan_id
     JOIN projects p ON (b.project_id = p.id OR pl.project_id = p.id)
  WHERE pa.state = ANY (confirmed_states())
  OR sb.state IN ('paid', 'pending_payment')
  GROUP BY b.user_id, u.zero_credits; 
    "
  end
end
