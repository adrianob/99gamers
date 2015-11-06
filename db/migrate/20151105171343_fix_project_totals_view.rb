class FixProjectTotalsView < ActiveRecord::Migration
  def change
      execute <<-SQL
      create table if not exists deps_saved_ddl
      (
        deps_id serial primary key, 
        deps_view_schema text, 
        deps_view_name text, 
        deps_ddl_to_run text
      );

      create or replace function deps_save_and_drop_dependencies(p_view_schema varchar, p_view_name varchar) returns void as
      $$
      declare
        v_curr record;
      begin
      for v_curr in 
      (
        select obj_schema, obj_name, obj_type from
        (
        with recursive recursive_deps(obj_schema, obj_name, obj_type, depth) as 
        (
          select p_view_schema, p_view_name, null::varchar, 0
          union
          select dep_schema::varchar, dep_name::varchar, dep_type::varchar, recursive_deps.depth + 1 from 
          (
            select ref_nsp.nspname ref_schema, ref_cl.relname ref_name, 
          rwr_cl.relkind dep_type,
            rwr_nsp.nspname dep_schema,
            rwr_cl.relname dep_name
            from pg_depend dep
            join pg_class ref_cl on dep.refobjid = ref_cl.oid
            join pg_namespace ref_nsp on ref_cl.relnamespace = ref_nsp.oid
            join pg_rewrite rwr on dep.objid = rwr.oid
            join pg_class rwr_cl on rwr.ev_class = rwr_cl.oid
            join pg_namespace rwr_nsp on rwr_cl.relnamespace = rwr_nsp.oid
            where dep.deptype = 'n'
            and dep.classid = 'pg_rewrite'::regclass
          ) deps
          join recursive_deps on deps.ref_schema = recursive_deps.obj_schema and deps.ref_name = recursive_deps.obj_name
          where (deps.ref_schema != deps.dep_schema or deps.ref_name != deps.dep_name)
        )
        select obj_schema, obj_name, obj_type, depth
        from recursive_deps 
        where depth > 0
        ) t
        group by obj_schema, obj_name, obj_type
        order by max(depth) desc
      ) loop

        insert into deps_saved_ddl(deps_view_schema, deps_view_name, deps_ddl_to_run)
        select p_view_schema, p_view_name, 'COMMENT ON ' ||
        case
        when c.relkind = 'v' then 'VIEW'
        when c.relkind = 'm' then 'MATERIALIZED VIEW'
        else ''
        end
        || ' ' || n.nspname || '.' || c.relname || ' IS ''' || replace(d.description, '''', '''''') || ''';'
        from pg_class c
        join pg_namespace n on n.oid = c.relnamespace
        join pg_description d on d.objoid = c.oid and d.objsubid = 0
        where n.nspname = v_curr.obj_schema and c.relname = v_curr.obj_name and d.description is not null;

        insert into deps_saved_ddl(deps_view_schema, deps_view_name, deps_ddl_to_run)
        select p_view_schema, p_view_name, 'COMMENT ON COLUMN ' || quote_ident(n.nspname) || '.' || quote_ident(c.relname) || '.' || quote_ident(a.attname) || ' IS ''' || replace(d.description, '''', '''''') || ''';'
        from pg_class c
        join pg_attribute a on c.oid = a.attrelid
        join pg_namespace n on n.oid = c.relnamespace
        join pg_description d on d.objoid = c.oid and d.objsubid = a.attnum
        where n.nspname = v_curr.obj_schema and c.relname = v_curr.obj_name and d.description is not null;
        
        insert into deps_saved_ddl(deps_view_schema, deps_view_name, deps_ddl_to_run)
        select p_view_schema, p_view_name, 'GRANT ' || privilege_type || ' ON ' || quote_ident(table_schema) || '.' || quote_ident(table_name) || ' TO ' || grantee
        from information_schema.role_table_grants
        where table_schema = v_curr.obj_schema and table_name = v_curr.obj_name;
        
        if v_curr.obj_type = 'v' then
          insert into deps_saved_ddl(deps_view_schema, deps_view_name, deps_ddl_to_run)
          select p_view_schema, p_view_name, 'CREATE VIEW ' || quote_ident(v_curr.obj_schema) || '.' || quote_ident(v_curr.obj_name) || ' AS ' || view_definition
          from information_schema.views
          where table_schema = v_curr.obj_schema and table_name = v_curr.obj_name;
        elsif v_curr.obj_type = 'm' then
          insert into deps_saved_ddl(deps_view_schema, deps_view_name, deps_ddl_to_run)
          select p_view_schema, p_view_name, 'CREATE MATERIALIZED VIEW ' || quote_ident(v_curr.obj_schema) || '.' || quote_ident(v_curr.obj_name) || ' AS ' || definition
          from pg_matviews
          where schemaname = v_curr.obj_schema and matviewname = v_curr.obj_name;
        end if;
        
        execute 'DROP ' ||
        case 
          when v_curr.obj_type = 'v' then 'VIEW'
          when v_curr.obj_type = 'm' then 'MATERIALIZED VIEW'
        end
        || ' ' || quote_ident(v_curr.obj_schema) || '.' || quote_ident(v_curr.obj_name);
        
      end loop;
      end;
      $$
      LANGUAGE plpgsql;

      create or replace function deps_restore_dependencies(p_view_schema varchar, p_view_name varchar) returns void as
      $$
      declare
        v_curr record;
      begin
      for v_curr in 
      (
        select deps_ddl_to_run 
        from deps_saved_ddl
        where deps_view_schema = p_view_schema and deps_view_name = p_view_name
        order by deps_id desc
      ) loop
        execute v_curr.deps_ddl_to_run;
      end loop;
      delete from deps_saved_ddl
      where deps_view_schema = p_view_schema and deps_view_name = p_view_name;
      end;
      $$
      LANGUAGE plpgsql;
    SQL
    execute "select deps_save_and_drop_dependencies('1', 'project_totals');"
    execute "drop view project_totals;"
    execute "
      CREATE OR REPLACE VIEW "1".project_totals AS
       with recurrent_projects as(
            SELECT pl.project_id,
            sum(pl.amount * (30/pl.days::numeric)) AS pledged,
            sum(pl.amount * (30/pl.days::numeric)) / pr.goal * 100::numeric AS progress,
            sum(s.gateway_fee) AS total_payment_service_fee,
            count(DISTINCT s.id) AS total_contributions
           FROM subscriptions s
             JOIN plans pl on pl.id = s.plan_id
             JOIN projects pr ON pl.project_id = pr.id
          WHERE s.state IN ('paid', 'pending_payment')
          GROUP BY pl.project_id, pr.id
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
