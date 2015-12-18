class SubscriptionDetail < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  belongs_to :subscription
  belongs_to :plan

  scope :public_active, ->(){ where("state IN ('paid', 'pending_payment')") }
  scope :active, ->{ joins(:plan).where("(state in ('paid','pending_payment')) OR (state = 'canceled' AND ((SELECT created_at from subscription_notifications sn where sn.subscription_id = subscription_details.id order by created_at DESC LIMIT 1 ) + (interval '1 days' * plans.days)) > current_timestamp)") }
end
