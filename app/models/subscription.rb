# coding: utf-8
class Subscription < ActiveRecord::Base
  include Shared::StateMachineHelpers

  belongs_to :plan
  belongs_to :user
  delegate :project, to: :plan
  has_many :subscription_notifications

  #do not show canceled
  scope :public_active, ->(){ where("subscriptions.state IN ('paid', 'pending_payment')").order('subscriptions.state').order('subscriptions.created_at desc') }

  scope :active, ->{ joins(:plan).where("(state in ('paid','pending_payment')) OR (state = 'canceled' AND ((SELECT created_at from subscription_notifications sn where sn.subscription_id = subscriptions.id order by created_at DESC LIMIT 1 ) + (interval '1 days' * plans.days)) > current_timestamp)").order('state').order('subscriptions.created_at desc') }
  scope :paid, -> do
   where("subscriptions.gateway_data->>'status' IN ('paid')")
  end

  def twitch_link
    self.user.twitch_link if self.user
  end

  def twitch_link=(val)
    binding.pry
    user.update_attribute :twitch_link, val
  end

  def payment_method
    gateway_data ? gateway_data["current_transaction"]["payment_method"] : nil
  end

  def credit_card_payment?
    payment_method == 'credit_card'
  end

  def slip_payment?
    payment_method == 'boleto'
  end

  def waiting_payment?
    ['unpaid','pending_payment'].include? self.state
  end

  def can_show_slip?
    self.slip_payment? && self.waiting_payment?
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
