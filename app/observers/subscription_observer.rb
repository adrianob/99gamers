class SubscriptionObserver < ActiveRecord::Observer
  observe :subscription

  def from_pending_payment_to_paid(subscription)
  end
  alias :from_unpaid_to_paid :from_pending_payment_to_paid

  def from_pending_payment_to_unpaid(subscription)
  end
  alias :from_paid_to_unpaid :from_pending_payment_to_unpaid

  def from_paid_to_canceled(subscription)
  end
  alias :from_pending_payment_to_canceled :from_paid_to_canceled
  alias :from_unpaid_to_canceled :from_paid_to_canceled
  alias :from_ended_to_canceled :from_paid_to_canceled

end

