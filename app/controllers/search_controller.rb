class SearchController < ApplicationController
  
  def index    
#    Millennium.login_to_api
#    Millennium.fetch_all_appointments
#
#    #Millennium.create_appointment
#    response = Millennium.fetch_all_employees
#    @employees = []
#    Nori.parse(response.body[:get_employee_listing_response][:get_employee_listing_result])[:get_employee_listing][:emp_info].each do |employee|
#      @employees << {id: employee[:iid], name: employee[:cfirstname].strip} if employee[:cfirstname].is_a?(String)
#    end
    #raise (@salon.get_employee_listing({})).inspect
  end

  def slots
    @app_date = params[:search][:date]
    #@app_time = params[:search][:time]
    free_time_slots = @salon.get_time_slots_by_date({'StartDate' => DateTime.parse(params[:search][:date]),
        'EndDate' => DateTime.parse(params[:search][:date])})
    @free_time_slots = (Hash[(free_time_slots.select{|key, value| value.eql?(true) && Time.parse(key).to_i >= Time.parse(params[:search][:time]).to_i}).sort_by { |k,v| k }[0..4]]).keys
    #@free_time_slots = (Hash[(free_time_slots.select{|key, value| value.eql?(true)}).sort_by { |k,v| k }[0..4]]).keys
  end

end
