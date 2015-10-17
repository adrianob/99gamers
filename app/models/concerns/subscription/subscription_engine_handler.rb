module Subscription::SubscriptionEngineHandler
  extend ActiveSupport::Concern

  included do

    def subscription_delegator
      self.try(:pagarme_subscription_delegator)
    end

  end
end


