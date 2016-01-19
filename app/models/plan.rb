# coding: utf-8
class Plan < ActiveRecord::Base
  include Plan::PlanEngineHandler
  include RankedModel

  belongs_to :project
  has_many :subscriptions
  has_many :benefits, class_name: 'PlanBenefit', dependent: :destroy

  validates_presence_of :amount, :name, :days
  validates_numericality_of :amount, greater_than_or_equal_to: 3.00, message: 'Valor deve ser maior ou igual a R$ 3'
  accepts_nested_attributes_for :benefits, reject_if: :all_blank, allow_destroy: true
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

  def public_total_subscribers
    subscriptions.public_active.count
  end
end
