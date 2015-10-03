# coding: utf-8
class Plan < ActiveRecord::Base
  include Plan::PlanEngineHandler
  belongs_to :project
  has_many :subscriptions

  def create_plan
    self.create_gateway_plan
  end

  def update_plan
    self.update_gateway_plan
  end
end
