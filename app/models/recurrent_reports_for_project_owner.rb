class RecurrentReportsForProjectOwner < ActiveRecord::Base
  acts_as_copy_target

  belongs_to :subscription

  scope :project_id, -> (project_id) { where(project_id: project_id) }

  def self.report
    report_sql = ""
    I18n.t('recurrent_report_to_project_owner').keys.each{
      |column| report_sql << "#{column} AS \"#{I18n.t("recurrent_report_to_project_owner.#{column}")}\","
    }

    self.select( report_sql.chomp ',')
  end
end

