class AddGateWayFeeToSubscriptionNotifications < ActiveRecord::Migration
  def change
    add_column(:subscription_notifications, :gateway_fee, :numeric)

    execute "select deps_save_and_drop_dependencies('1', 'project_totals');"
    execute "drop view project_totals;"
    execute "ALTER TABLE subscriptions DROP COLUMN gateway_fee;"
    execute "
      CREATE OR REPLACE VIEW \"1\".project_totals AS
       with recurrent_projects as(
            with total_fee AS(
              SELECT sum(sn.gateway_fee) as total_payment_service_fee, p.id as project_id from subscription_notifications sn
                JOIN subscriptions s on s.id = sn.subscription_id 
                JOIN plans pl on pl.id = s.plan_id 
                JOIN projects p on p.id  = pl.project_id  
                GROUP by p.id
            )
            SELECT pl.project_id,
            sum(pl.amount * (30/pl.days::numeric)) AS pledged,
            sum(pl.amount * (30/pl.days::numeric)) / pr.goal * 100::numeric AS progress,
            tf.total_payment_service_fee as total_payment_service_fee,
            count(DISTINCT s.id) AS total_contributions
           FROM subscriptions s
             JOIN plans pl on pl.id = s.plan_id
             JOIN projects pr ON pl.project_id = pr.id
             JOIN total_fee tf on tf.project_id = pr.id
          WHERE s.state IN ('paid', 'pending_payment')
          GROUP BY pl.project_id, pr.id, tf.total_payment_service_fee
      ),
      all_or_nothing_projects as(
          SELECT c.project_id,
          sum(p.value) AS pledged,
          sum(p.value) / projects.goal * 100::numeric AS progress,
          sum(p.gateway_fee) AS total_payment_service_fee,
          count(DISTINCT c.id) AS total_contributions
         FROM contributions c
           JOIN projects ON c.project_id = projects.id
           JOIN payments p ON p.contribution_id = c.id
        WHERE p.state = ANY (confirmed_states())
        GROUP BY c.project_id, projects.id
      )

      SELECT 
      p.id as project_id,
      (CASE ft.name
        WHEN 'recurrent' THEN rp.pledged
        ELSE anp.pledged
        END
      ) AS pledged,

      (CASE ft.name
        WHEN 'recurrent' THEN rp.progress
        ELSE anp.progress
        END
      ) AS progress,
      (CASE ft.name
        WHEN 'recurrent' THEN rp.total_payment_service_fee
        ELSE anp.total_payment_service_fee
        END
      ) AS total_payment_service_fee,
      (CASE ft.name
        WHEN 'recurrent' THEN rp.total_contributions
        ELSE anp.total_contributions
        END
      ) AS total_contributions
      FROM
      projects p 
      join funding_types ft on ft.id = p.funding_type_id
      LEFT JOIN recurrent_projects rp ON rp.project_id = p.id
      LEFT JOIN all_or_nothing_projects anp ON anp.project_id = p.id ;
  "
    execute "select deps_restore_dependencies('1', 'project_totals');"
  end
end
