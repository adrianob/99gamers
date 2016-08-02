class AddRecurrentToHome < ActiveRecord::Migration
  def change
    execute <<-SQL
    drop view projects_for_home;
   create view projects_for_home as 
    WITH recommended_projects AS (
         SELECT 'recommended'::text AS origin,
            recommends.id,
            recommends.name,
            recommends.funding_type_id,
            recommends.expires_at,
            recommends.user_id,
            recommends.category_id,
            recommends.goal,
            recommends.headline,
            recommends.video_url,
            recommends.short_url,
            recommends.created_at,
            recommends.updated_at,
            recommends.about_html,
            recommends.recommended,
            recommends.home_page_comment,
            recommends.permalink,
            recommends.video_thumbnail,
            recommends.state,
            recommends.online_days,
            recommends.online_date,
            recommends.traffic_sources,
            recommends.more_links,
            recommends.first_contributions AS first_backers,
            recommends.uploaded_image,
            recommends.video_embed_url
           FROM projects recommends
          WHERE recommends.recommended AND recommends.state::text = 'online'::text
          ORDER BY (random())
         LIMIT 3
        ), recurrent_projects AS (
         SELECT 'recurrent'::text AS origin,
            recurrents.id,
            recurrents.name,
            recurrents.funding_type_id,
            recurrents.expires_at,
            recurrents.user_id,
            recurrents.category_id,
            recurrents.goal,
            recurrents.headline,
            recurrents.video_url,
            recurrents.short_url,
            recurrents.created_at,
            recurrents.updated_at,
            recurrents.about_html,
            recurrents.recommended,
            recurrents.home_page_comment,
            recurrents.permalink,
            recurrents.video_thumbnail,
            recurrents.state,
            recurrents.online_days,
            recurrents.online_date,
            recurrents.traffic_sources,
            recurrents.more_links,
            recurrents.first_contributions AS first_backers,
            recurrents.uploaded_image,
            recurrents.video_embed_url
           FROM projects recurrents
          WHERE recurrents.funding_type_id = (select id from funding_types ft where ft.name = 'recurrent') AND recurrents.state::text = 'online'::text
          ORDER BY (random())
         LIMIT 3
        ), recents_projects AS (
         SELECT 'recents'::text AS origin,
            recents.id,
            recents.name,
            recents.funding_type_id,
            recents.expires_at,
            recents.user_id,
            recents.category_id,
            recents.goal,
            recents.headline,
            recents.video_url,
            recents.short_url,
            recents.created_at,
            recents.updated_at,
            recents.about_html,
            recents.recommended,
            recents.home_page_comment,
            recents.permalink,
            recents.video_thumbnail,
            recents.state,
            recents.online_days,
            recents.online_date,
            recents.traffic_sources,
            recents.more_links,
            recents.first_contributions AS first_backers,
            recents.uploaded_image,
            recents.video_embed_url
           FROM projects recents
          WHERE recents.state::text = 'online'::text AND (now() - recents.online_date) <= '2 months'::interval AND NOT (recents.id IN ( SELECT recommends.id
                   FROM recommended_projects recommends))
          ORDER BY (random())
         LIMIT 3
        ), expiring_projects AS (
         SELECT 'expiring'::text AS origin,
            expiring.id,
            expiring.name,
            expiring.funding_type_id,
            expiring.expires_at,
            expiring.user_id,
            expiring.category_id,
            expiring.goal,
            expiring.headline,
            expiring.video_url,
            expiring.short_url,
            expiring.created_at,
            expiring.updated_at,
            expiring.about_html,
            expiring.recommended,
            expiring.home_page_comment,
            expiring.permalink,
            expiring.video_thumbnail,
            expiring.state,
            expiring.online_days,
            expiring.online_date,
            expiring.traffic_sources,
            expiring.more_links,
            expiring.first_contributions AS first_backers,
            expiring.uploaded_image,
            expiring.video_embed_url
           FROM projects expiring
          WHERE expiring.state::text = 'online'::text AND expiring.expires_at <= (now() + '14 days'::interval) AND NOT (expiring.id IN ( SELECT recommends.id
                   FROM recommended_projects recommends
                UNION
                 SELECT recents.id
                   FROM recents_projects recents))
          ORDER BY (random())
         LIMIT 3
        )
 SELECT recommended_projects.origin,
    recommended_projects.id,
    recommended_projects.name,
    recommended_projects.funding_type_id,
    recommended_projects.expires_at,
    recommended_projects.user_id,
    recommended_projects.category_id,
    recommended_projects.goal,
    recommended_projects.headline,
    recommended_projects.video_url,
    recommended_projects.short_url,
    recommended_projects.created_at,
    recommended_projects.updated_at,
    recommended_projects.about_html,
    recommended_projects.recommended,
    recommended_projects.home_page_comment,
    recommended_projects.permalink,
    recommended_projects.video_thumbnail,
    recommended_projects.state,
    recommended_projects.online_days,
    recommended_projects.online_date,
    recommended_projects.traffic_sources,
    recommended_projects.more_links,
    recommended_projects.first_backers,
    recommended_projects.uploaded_image,
    recommended_projects.video_embed_url
   FROM recommended_projects
UNION
 SELECT recurrent_projects.origin,
    recurrent_projects.id,
    recurrent_projects.name,
    recurrent_projects.funding_type_id,
    recurrent_projects.expires_at,
    recurrent_projects.user_id,
    recurrent_projects.category_id,
    recurrent_projects.goal,
    recurrent_projects.headline,
    recurrent_projects.video_url,
    recurrent_projects.short_url,
    recurrent_projects.created_at,
    recurrent_projects.updated_at,
    recurrent_projects.about_html,
    recurrent_projects.recommended,
    recurrent_projects.home_page_comment,
    recurrent_projects.permalink,
    recurrent_projects.video_thumbnail,
    recurrent_projects.state,
    recurrent_projects.online_days,
    recurrent_projects.online_date,
    recurrent_projects.traffic_sources,
    recurrent_projects.more_links,
    recurrent_projects.first_backers,
    recurrent_projects.uploaded_image,
    recurrent_projects.video_embed_url
   FROM recurrent_projects
UNION
 SELECT recents_projects.origin,
    recents_projects.id,
    recents_projects.name,
    recents_projects.funding_type_id,
    recents_projects.expires_at,
    recents_projects.user_id,
    recents_projects.category_id,
    recents_projects.goal,
    recents_projects.headline,
    recents_projects.video_url,
    recents_projects.short_url,
    recents_projects.created_at,
    recents_projects.updated_at,
    recents_projects.about_html,
    recents_projects.recommended,
    recents_projects.home_page_comment,
    recents_projects.permalink,
    recents_projects.video_thumbnail,
    recents_projects.state,
    recents_projects.online_days,
    recents_projects.online_date,
    recents_projects.traffic_sources,
    recents_projects.more_links,
    recents_projects.first_backers,
    recents_projects.uploaded_image,
    recents_projects.video_embed_url
   FROM recents_projects
UNION
 SELECT expiring_projects.origin,
    expiring_projects.id,
    expiring_projects.name,
    expiring_projects.funding_type_id,
    expiring_projects.expires_at,
    expiring_projects.user_id,
    expiring_projects.category_id,
    expiring_projects.goal,
    expiring_projects.headline,
    expiring_projects.video_url,
    expiring_projects.short_url,
    expiring_projects.created_at,
    expiring_projects.updated_at,
    expiring_projects.about_html,
    expiring_projects.recommended,
    expiring_projects.home_page_comment,
    expiring_projects.permalink,
    expiring_projects.video_thumbnail,
    expiring_projects.state,
    expiring_projects.online_days,
    expiring_projects.online_date,
    expiring_projects.traffic_sources,
    expiring_projects.more_links,
    expiring_projects.first_backers,
    expiring_projects.uploaded_image,
    expiring_projects.video_embed_url
   FROM expiring_projects; 
    SQL
  end
end
