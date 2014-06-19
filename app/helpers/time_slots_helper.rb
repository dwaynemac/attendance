module TimeSlotsHelper
  
  def already_selected_day_name
    selected_day = []
    Date::DAYNAMES.map{|day| day.downcase}.each do |day_name|
      selected_day << day_name.capitalize if @time_slot[day_name]
    end  
    selected_day
  end

end
