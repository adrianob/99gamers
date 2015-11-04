class FixContributedProjects < ActiveRecord::Migration
  def change
     execute "
      CREATE OR REPLACE VIEW contributed_projects AS
        SELECT distinct(p.*), u.id AS paying_user_id FROM users u 
          LEFT JOIN contributions c ON c.user_id = u.id
          LEFT JOIN subscriptions s ON s.user_id = u.id
          LEFT JOIN plans pl ON pl.id = s.plan_id
          JOIN projects p ON ( p.id = pl.project_id OR p.id = c.project_id )
          WHERE c.was_confirmed OR s.state IN ('paid', 'pending_payment');
    "
  end
end
