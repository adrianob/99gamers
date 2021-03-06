class PlansController < ApplicationController
  respond_to :html, :json
  helper_method :resource, :parent

  def index
    render layout: false
  end

  def sort
    authorize resource
    resource.update_attribute :row_order_position, params[:plan][:row_order_position]
    render nothing: true
  end

  def resource
    @plan ||= parent.plans.find params[:id]
  end

  def parent
    @project ||= Project.find params[:project_id]
  end
end
