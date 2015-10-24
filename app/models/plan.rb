# coding: utf-8
class Plan < ActiveRecord::Base
  include Plan::PlanEngineHandler
  include RankedModel

  belongs_to :project
  has_many :subscriptions
  scope :active, ->{ where(enabled: true) }
  ranks :row_order, with_same: :project_id

  def create_plan
    self.create_gateway_plan
  end

  def destroy_plan
    self.destroy_gateway_plan
  end

  def update_plan
    self.update_gateway_plan
  end

  def total_subscribers
    subscriptions.active.count
  end
end
