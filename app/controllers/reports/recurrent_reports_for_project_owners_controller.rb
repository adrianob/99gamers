class Reports::RecurrentReportsForProjectOwnersController < ApplicationController
  respond_to :csv, :xls

  has_scope :project_id

  def index
    authorize project, :update?
    respond_to do |format|
      format.csv do
        send_data collection.copy_to_string, filename: "#{project.name}.csv"

      end

      format.xls do
        send_data collection.to_xls(
          columns: I18n.t('recurrent_report_to_project_owner').values
        ), filename: "#{project.name}.xls"
      end
    end
  end

  protected

  def collection
    @collection ||= apply_scopes(RecurrentReportsForProjectOwner.report)
    @collection
  end

  def project
    @project ||= Project.find params[:project_id]
  end

  def self.policy_class
    ProjectPolicy
  end
end

