class FixCreditsOnUserTotals < ActiveRecord::Migration
  def up
    execute <<-SQL
    DROP MATERIALIZED VIEW user_totals;

    CREATE MATERIALIZED VIEW user_totals AS
      SELECT b.user_id AS id,
        b.user_id,
        count(DISTINCT b.project_id) AS total_contributed_projects,
        sum(pa.value) AS sum,
        count(DISTINCT b.id) AS count,
        (
          CASE
            WHEN u.zero_credits THEN
             0::numeric
            ELSE
              sum(
                CASE
                  WHEN lower(pa.gateway) = 'pagarme' THEN 0::numeric
                  WHEN p.state::text <> 'failed'::text AND NOT uses_credits(pa.*) THEN 0::numeric
                  WHEN p.state::text = 'failed'::text AND uses_credits(pa.*) THEN 0::numeric
                  WHEN p.state::text = 'failed'::text AND ((pa.state = ANY (ARRAY['pending_refund'::character varying::text, 'refunded'::character varying::text])) AND NOT uses_credits(pa.*) OR uses_credits(pa.*) AND NOT (pa.state = ANY (ARRAY['pending_refund'::character varying::text, 'refunded'::character varying::text]))) THEN 0::numeric
                  WHEN p.state::text = 'failed'::text AND NOT uses_credits(pa.*) AND pa.state = 'paid'::text THEN pa.value
                  ELSE pa.value * (-1)::numeric
                END)
            END
        )  AS credits
      FROM contributions b
        JOIN payments pa ON b.id = pa.contribution_id
        JOIN projects p ON b.project_id = p.id
        JOIN users u ON u.id = b.user_id
      WHERE pa.state = ANY (confirmed_states())
      GROUP BY b.user_id, u.zero_credits;


    SQL
  end

  def down
  end
end
