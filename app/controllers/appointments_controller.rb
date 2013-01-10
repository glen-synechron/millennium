class AppointmentsController < ApplicationController

  before_filter :authenticate_user!

  def index    
  end

  def book_appointment
    time = params[:appointment][:time].sub(/:/,'')
    date =  DateTime.parse(params[:appointment][:date])
    conflict = @salon.check_conflict({
        'SelectDate' => date,
        'ServId' => params[:appointment][:service],
        'EmployeeId' => params[:appointment][:employee],
        'StartLen' => 0,
        'GapLen' => 0,
        'FinishLen' => 1,
        'Time' => time,
        'ClientId' => current_user.client_id
      })
    if conflict
      flash[:error] = "Conflict when booking appointment"
    else
      appointment = @salon.put_appointment({
          'Appointment' => {
            'AppointmentDetails' => {
              'AppointmentDetail' => {
                'StartTime' => time,
                'EmployeeId' => params[:appointment][:employee],
                'ClientId' => current_user.client_id,
                'ServiceId' => params[:appointment][:service],
                'StartLength' => 0,
                'GapLength' => 0,
                'FinishLength' => 1,
                'AppointmentType' => 5,
                'ResourceId' => 0
              }
            },
            'PayingClientId' => current_user.client_id,
            'Notes' => 'Booked VIA the SDK',
            'AppointmentDate' => date,
            'CategoryId' => -12
          }
        })
        flash[:notice] = "Appointment booked for the user #{current_user.name} with appointment id #{appointment[:appointment_id]}"
    end
    redirect_to :back
  end

  def check_price
    @price = @salon.get_service_price({
        'ClientId' => current_user.client_id,
        'EmpId' => params[:emp_id],
        'ServiceId' => params[:service_id],
        'IncludeTax' => 0
      })
    
  end
end
