class CreateRecurrentReportsForProjectOwner < ActiveRecord::Migration
  def change
    execute <<-SQL
      CREATE OR REPLACE VIEW recurrent_reports_for_project_owners AS
        SELECT p.id  as project_id,pl.name as plan_name, pl.amount as amount, pl.days as days, u.name as user_name, u.email as user_email
        FROM subscriptions s
        join plans pl on pl.id = s.plan_id
        join users u on u.id = s.user_id
        join projects p on p.id = pl.project_id
        WHERE  s.state = 'paid';
    SQL
  end
end
