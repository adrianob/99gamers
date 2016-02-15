class SubscriptionDetail < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  belongs_to :subscription
  belongs_to :plan


  delegate :pending_payment?, to: :subscription

  scope :public_active, ->(){ joins(:subscription).where("subscriptions.state IN ('paid', 'pending_payment')").order('subscriptions.state').order('subscriptions.created_at desc') }
  scope :active, ->{ joins(:plan).joins(:subscription).where("(subscriptions.state in ('paid','pending_payment')) OR (subscriptions.state = 'canceled' AND ((SELECT created_at from subscription_notifications sn where sn.subscription_id = subscription_details.id order by created_at DESC LIMIT 1 ) + (interval '1 days' * plans.days)) > current_timestamp)").order('subscriptions.state').order('subscriptions.created_at desc') }

end
