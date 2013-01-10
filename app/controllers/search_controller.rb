class SearchController < ApplicationController
  
  def index    
  end

  def slots
    @app_date = params[:search][:date]
    free_time_slots = @salon.get_time_slots_by_date({'StartDate' => DateTime.parse(params[:search][:date]),
        'EndDate' => DateTime.parse(params[:search][:date])})
    @free_time_slots = (Hash[(free_time_slots.select{|key, value| value.eql?(true) && Time.parse(key).to_i >= Time.parse(params[:search][:time]).to_i}).sort_by { |k,v| k }[0..4]]).keys
    #@free_time_slots = (Hash[(free_time_slots.select{|key, value| value.eql?(true)}).sort_by { |k,v| k }[0..4]]).keys
  end

end
