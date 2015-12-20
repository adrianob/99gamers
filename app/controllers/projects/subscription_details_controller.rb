class Projects::SubscriptionDetailsController < ApplicationController
  has_scope :page, default: 1

  def index
    render collection
  end

  def collection
    if current_user && (current_user.admin? || parent.user == current_user)
      @subscriptions ||= apply_scopes(parent.subscription_details).active.order("created_at DESC").per(10)
    else
      @subscriptions ||= apply_scopes(parent.subscription_details).public_active.order("created_at DESC").per(10)
    end
  end

  def parent
    @project ||= Project.find params[:project_id]
  end
end

