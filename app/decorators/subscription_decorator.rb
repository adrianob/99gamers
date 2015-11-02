class SubscriptionDecorator < Draper::Decorator
  decorates :subscription
  include Draper::LazyHelpers

  def display_payment_details
    I18n.t("contribution.payment_details.#{source.payment_method.underscore}")
  end

  def display_value
    number_to_currency source.plan.amount
  end

  def display_date date_field
    I18n.l(source[date_field.to_sym].to_date) if source[date_field.to_sym]
  end

  def display_slip_url
    gateway_data = source.try(:gateway_data)
    return gateway_data['current_transaction']['boleto_url'] if gateway_data.present?
  end

  def display_status
    state = source.state
    I18n.t("payment.state.#{state}", date: display_date("#{state}_at"))
  end
end


