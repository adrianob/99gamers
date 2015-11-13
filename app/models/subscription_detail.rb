class SubscriptionDetail < ActiveRecord::Base
  belongs_to :user
  belongs_to :project

  scope :active, ->(){ where("state IN ('paid', 'pending_payment')") }
end
