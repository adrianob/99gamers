module Project::ErrorGroups
  extend ActiveSupport::Concern

  included do
    begin
      ATTR_GROUPS = {
        basics: [:name, :permalink, :category_id],
        description: [:about_html],
        budget: [:budget],
        transfers: [:'project_transfers'],
        card: [:uploaded_image, :headline],
        video: [:video_url, :cover_image],
        plan: [:'plans.amount', :'plans.name', :'plans.days'],
        reward: [:'rewards.minimum_value', :'rewards.deliver_at'],
        goal: [:'goals.value', :goal],
        user_about: [:'user.uploaded_image', :'user.name', :'user.about_html'],
        user_settings: ProjectAccount.attribute_names.map{|attr| ('project_account.' + attr).to_sym} << :account << :'account.agency_size'
      }
    rescue Exception => e
      puts "problem while using ErrorGroups concenr:\n '#{e.message}'"
    end

    def error_included_on_group? error_attr, group_name
      ATTR_GROUPS[:goal] << :online_days if !self.recurrent?
      ATTR_GROUPS[:reward] << :'rewards.size' if !self.recurrent?
      ATTR_GROUPS[:goal] << :'goals.size' if self.recurrent?
      Project::ATTR_GROUPS[group_name.to_sym].include?(error_attr)
    end

    def has_errors_for?(field)
      errors.include?(field)
    end
  end
end
