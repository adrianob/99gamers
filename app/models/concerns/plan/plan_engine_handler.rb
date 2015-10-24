module Plan::PlanEngineHandler
  extend ActiveSupport::Concern

  included do

    def create_gateway_plan
      plan_delegator.try(:create_plan)
    end

    def destroy_gateway_plan
      plan_delegator.try(:destroy_plan)
    end

    def update_gateway_plan
      plan_delegator.try(:update_plan)
    end
    # References to current payment engine delegator
    def plan_delegator
      self.try(:pagarme_plan_delegator)
    end

  end
end

