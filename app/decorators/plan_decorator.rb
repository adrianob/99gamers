class PlanDecorator < Draper::Decorator
  decorates :plan
  include Draper::LazyHelpers
  include AutoHtml

  def short_description
    truncate source.description, length: 35
  end

  def medium_description
    truncate source.description, length: 65
  end

  def last_description
    if source.versions.present?
      reward = source.versions.last.reify(has_one: true)
      auto_html(reward.description) { simple_format; link(target: '_blank') }
    end
  end

  def display_description
    auto_html(source.description){ html_escape; simple_format }
  end
end
