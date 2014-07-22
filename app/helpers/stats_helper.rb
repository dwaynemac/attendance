module StatsHelper

  def show_period
    if params[:easy_period]
      l(@stats.start_on, format: :month).capitalize
    else
      "#{l(@stats.start_on, format: :default)} - #{l(@stats.end_on, format: :default)}"
    end
  end
end
