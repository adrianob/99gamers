class SubscriptionNotification < ActiveRecord::Base
  belongs_to :subscription
  delegate :plan, to: :subscription

  def payment_method
    subscription.payment_method
  end

  def gateway_data
    subscription.gateway_data
  end

  # This methods should be called by payments engines
  def deliver_process_notification
    deliver_contributor_notification(:processing_payment)
  end

  def deliver_slip_canceled_notification
    deliver_contributor_notification(:contribution_canceled_slip)
  end

  private

  def deliver_contributor_notification(template_name)
    self.notify_to_contributor(template_name)
  end

end

