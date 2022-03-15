module StatsHelper

  def show_period
    if params[:easy_period]
      l(@stats.start_on, format: :month).capitalize
    else
      "#{l(@stats.start_on, format: :default)} - #{l(@stats.end_on, format: :default)}"
    end
  end

  def active_pill( period )
    if (period.nil? && params[:easy_period].nil?) || (period.try(:to_s) == params[:easy_period].try(:to_s))
      "class=active"
    end
  end
end
