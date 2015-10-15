# coding: utf-8
class Subscription < ActiveRecord::Base
  belongs_to :plan
  belongs_to :user

  scope :paid, -> do
   where("subscriptions.gateway_data->>'status' IN ('paid')")
  end

  def payment_method
    gateway_data["current_transaction"]["payment_method"]
  end

  def paid?
    gateway_data["status"] == 'paid'
  end

  def credit_card_payment?
    payment_method == 'credit_card'
  end

  def slip_payment?
    payment_method == 'boleto'
  end
end

