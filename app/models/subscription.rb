# coding: utf-8
class Subscription < ActiveRecord::Base
  include Shared::StateMachineHelpers

  belongs_to :plan
  belongs_to :user
  has_many :subscription_notifications

  scope :active, ->{ with_states(['paid','pending_payment']) }
  scope :paid, -> do
   where("subscriptions.gateway_data->>'status' IN ('paid')")
  end

  def payment_method
    gateway_data["current_transaction"]["payment_method"]
  end

  def credit_card_payment?
    payment_method == 'credit_card'
  end

  def slip_payment?
    payment_method == 'boleto'
  end

  state_machine :state, initial: :unpaid do
    state :pending_payment
    state :unpaid
    state :canceled
    state :ended
    state :paid

    event :pay do
      transition [:pending_payment, :unpaid ] => :paid
    end

    event :disable do
      transition [:pending_payment, :paid] => :unpaid
    end

    event :cancel do
      transition all => :canceled
    end

    event :require_payment do
      transition :paid => :pending_payment
    end

    after_transition do |subscription, transition|
      subscription.notify_observers :"from_#{transition.from}_to_#{transition.to}"

      to_column = "#{transition.to}_at".to_sym
      subscription.update_attribute(to_column, DateTime.current) if subscription.has_attribute?(to_column)
    end
  end
end
