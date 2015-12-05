class GoalDecorator < Draper::Decorator
  decorates :goal
  include Draper::LazyHelpers
  include AutoHtml

  def progress_bar
    width = source.progress > 100 ? 100 : source.progress
    content_tag(:div, nil, class: 'meter-fill', style: "width: #{width}%;")
  end

  def display_value
    "<div class=\"meta-info\"> <span class=\"meta-valor\">#{number_to_currency source.value}</span>  <span class=\"meta-porc\">(#{number_with_precision source.progress.floor, precision: 0}% alcançada)</span> </div>".html_safe
  end

  def short_description
    truncate source.description, length: 35
  end

  def medium_description
    truncate source.description, length: 65
  end

  def display_description
    auto_html(source.description){ html_escape; simple_format }
  end
end
