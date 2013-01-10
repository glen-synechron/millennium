module Millennium
  
  XMLNS = "http://www.harms-software.com/Millennium.SDK"

  def get_all_appointments_by_date(options)
    body = options
    response = request(__method__, body)
    all_appointments = Nori.parse(response.body[:get_all_appointments_by_date_response][:get_all_appointments_by_date_result])[:get_all_apptointments_by_date][:apptointments]
    
    # Three possibilities of all_appointments
    # 1. nil converted to array
    # 2. {} placed in an array
    # 3. [] left as is
    all_appointments = all_appointments.nil? ? [] : (all_appointments.is_a?(Hash)? [all_appointments] : all_appointments)

    appointments = []
    all_appointments.each do |appointment|
      appointment_start_time, appointment_end_time = format_start_end_time(appointment[:ddate], appointment[:ctimeofday], appointment[:nfinishlen])
      appointment_id = appointment[:iid].to_i
      employee_id = appointment[:iempid].to_i
      client_id = appointment[:iclientid].to_i
      service_id = appointment[:iservid].to_i
      appointments << {appointment_id: appointment_id, employee_id: employee_id, client_id: client_id, service_id: service_id, start_time: appointment_start_time, end_time: appointment_end_time}
    end
    appointments
  end

  # date is a DateTime object
  # timeofday is a string such as "1100", "1445"
  # finishlen is a string such a "1.5", "1.0"
  def format_start_end_time(appointment_date, timeofday, finishlen)
    appointment_start_hour = timeofday.slice(0,2).to_i
    appointment_start_minute = timeofday.slice(2,2).to_i
    appointment_start_time = DateTime.new(appointment_date.year, appointment_date.month, appointment_date.day, appointment_start_hour, appointment_start_minute)
    appointment_end_hour = finishlen.to_f.to_i
    appointment_end_minute = case finishlen.to_f.abs.modulo(1)
        when 0
          0
        when 0.25
          15
        when 0.5
          30
        when 0.75
          45
        end
    appointment_end_time = DateTime.new(appointment_start_time.year, appointment_start_time.month, appointment_start_time.day, appointment_start_time.hour + appointment_end_hour, appointment_start_time.minute + appointment_end_minute)
    [appointment_start_time, appointment_end_time]
  end

  # only considers the start_date not the end_date
  # also considering that the start time is 9 am and the end time is 6 pm.
  # this can vary on a per salon basis.
  def get_time_slots_by_date(options)
    appointments = get_all_appointments_by_date(options)
    date = DateTime.new(options['StartDate'].year, options['StartDate'].month, options['StartDate'].day, 9, 0)
    time_slots = {}
    current_slot = date.to_time.utc
    36.times do
      time_slots.merge!(current_slot.to_s(:to_hh_mm) => true)
      current_slot = current_slot.to_time.utc + 15.minutes
    end
    appointments.each do |appointment|
      slots_utilized = ((appointment[:end_time].to_time.utc - appointment[:start_time].to_time.utc)/60/15).to_i
      slot_time = appointment[:start_time].to_time.utc
      slots_utilized.times do
        time_slots.merge!({slot_time.to_s(:to_hh_mm) => false})
        slot_time += 15.minutes
      end
    end
    time_slots
  end

  def get_appointment(options)
    body = options
    response = request(__method__, body)
    response.body[:get_appointment_response][:get_appointment_result]
  end

  def get_client_info_by_email(options)
    body = options
    response = request(__method__, body)
    client = Nori.parse(response.body[:get_client_info_by_email_response][:get_client_info_by_email_result])[:get_client_info_by_email][:clients]
    {client_id: client[:iid].to_i, email: client[:cemail].strip, first_name: client[:cfirstname].strip, last_name: client[:clastname].strip}
  end

  # Returns array of hashes of employees
  # [{emp_id: 1, emp_name: "Shripad Joshi"}]
  def get_employee_listing(options)
    body = options
    response = request(__method__, body)
    employees = []
    Nori.parse(response.body[:get_employee_listing_response][:get_employee_listing_result])[:get_employee_listing][:emp_info].each do |employee|
      employees << {employee_id: employee[:iid].to_i, name: "#{employee[:cfirstname].strip} #{employee[:clastname].strip}" } unless employee[:cfirstname].is_a?(Hash)
    end
    employees
  end

  # Returns array of hashes of services
  # [{:service_id=>"3", :service_code=>"BT", :service_description=>"Body Scrubs"]
  def get_service_listing(options)
    body = options
    response = request(__method__, body)
    services = []
    Nori.parse(response.body[:get_service_listing_response][:get_service_listing_result])[:get_service_listing][:services].each do |service|
      services << {service_id: service[:iid],service_class: service[:cdescript].strip}
    end
    services
  end

   # get_service_price method
  # Returns the price for the service, given the client and the employee
  def get_service_price(options)
    body = options
    response = request(__method__, body)
    response.body[:get_service_price_response][:get_service_price_result].to_f
  end

#  price = salon.get_service_price({
#  'ClientId' => 6,
#  'EmpId' => 4,
#  'ServiceId' => 2,
#  'IncludeTax' => 0})

  # Returns true in case of conflict
  def check_conflict(options)
    body = options
    response = request(__method__, body)
    response.body[:check_conflict_response][:check_conflict_result]
  end

  # What is resource?
  # resource is not the same as employee
  def check_resource_conflict(options)
    body = options
    response = request(__method__, body)
    response.body[:check_resource_conflict_response][:check_resource_conflict_result]
  end


  def put_client(options)
    body = options
    response = request(__method__, body)
    {client_id: response.body[:put_client_response][:put_client_result]}
  end

  def put_appointment(options)
    body = options
    response = request(__method__, body)
    {appointment_id: response.body[:put_appointment_response][:put_appointment_result]}
  end

  def set_environment_namespace
    Savon.configure do |c|
      c.env_namespace = :soap
    end
  end

  def set_savon_client
    Savon::Client.new do |wsdl|
      wsdl.document = "http://#{self.server}/MillenniumSDK/millenniumsdk.asmx?WSDL"
    end
  end

  def logon
    response = request(__method__, {'User' => self.user, 'Password' => self.password})

    # Checking the response of the login method to see if correct
    unless response.body[:logon_response][:logon_result]
      puts "Logon incorrect"
      exit
    else
      # Saving the session_id response after the login into a variable.
      self.update_attributes(session_id: response.header[:session_info][:session_id])
    end
  end

  def log_off
    response = request(__method__, {})
    response.body[:log_off_response][:log_off_result]
  end

  def request(name, body)
    set_environment_namespace
    @client = set_savon_client
    begin
      response = @client.request(name, {:xmlns => XMLNS}) do
        soap.header = {
          'MillenniumInfo' => {'MillenniumGuid' => self.guid}, 
          'SessionInfo' => {'SessionId' => self.session_id}, 
          :attributes! => {"SessionInfo" => {:xmlns => XMLNS}, "MillenniumInfo" => {:xmlns => XMLNS}  }
        }
        soap.body = body
      end
    rescue Savon::SOAP::Fault => e
      if e.inspect.match(/Invalid Session Id or the session has expired. Please Logon again./)
        logon
        retry
      else
        raise
      end
    rescue Exception => e
      puts "Unhandled Exception #{e} => #{e.inspect}"
    end
    response
  end
end


#class Salon
#  include Millennium
#  attr_accessor :id, :server, :user, :password, :guid, :session_id
#  def initialize(options)
#    @id = options[:id]
#    @server = options[:server]
#    @user = options[:user]
#    @password = options[:password]
#    @guid = options[:guid]
#    @session_id = options[:session_id]
#  end
#
#end

# these are the attributes that needed to be added to the Salon model
# salon start_time
# salon end_time
#salon = Salon.new({id: 1, server: 'ec2-23-22-112-83.compute-1.amazonaws.com',
#  user: 'sdktest', password: 'sdk1234*', guid: "2282590F-B094-7FA1-5132-51667C35D70E", session_id: '234234242'})


#appointments = salon.get_all_appointments_by_date({
#        'StartDate' => DateTime.new(2013,1,9),
#        'EndDate' => DateTime.new(2013,1,9)
#      })

#appointment_slots = salon.get_free_time_slots_by_date({
#        'StartDate' => DateTime.new(2013,1,9),
#        'EndDate' => DateTime.new(2013,1,9)
#      })
#salon.get_appointment({'AppointmentId' => 7})

#salon.get_client_info_by_email({'email' => 'shripad.joshi@synechron.com'})
#client = salon.put_client({'client' => {
#      'LastName' => 'Shukla', 
#      'FirstName' => 'Abhishek', 
#      'ReferralTypeId' => 4,
#      'EmailAddress; => 'abhishek.shukla1@synechron.com'
#    }})

#salon.put_appointment({
#    'Appointment' => {
#      'AppointmentDetails' => {
#        'AppointmentDetail' => {
#          'StartTime' => '1400',
#          'EmployeeId' => 2,
#          'ClientId' => 6,
#          'ServiceId' => 2,
#          'StartLength' => 1.5,
#          'GapLength' => 0,
#          'FinishLength' => 0, 
#          'AppointmentType' => 5,
#          'ResourceId' => 0
#        }
#      },
#      'PayingClientId' => 3,
#      'Notes' => 'Booked VIA the SDK',
#      'AppointmentDate' => Date.today,
#      'CategoryId' => -12    
#    }
#  })
#salon.check_conflict({
#      'SelectDate' => Date.today, 
#      'ServId' => 2, 
#      'EmployeeId' => 4,
#      'StartLen' => 1.5,
#      'GapLen' => 0,
#      'FinishLen' => 0,
#      'Time' => '1400',
#      'ClientId' => 6
#  })

#salon.check_resource_conflict({
#      'SelectDate' => Date.today, 
#      'ServId' => 2, 
#      'ResourceId' => 4,
#      'StartLen' => 1.5,
#      'GapLen' => 0,
#      'FinishLen' => 0,
#      'Time' => '1400',
#      'ClientId' => 6
#  })

#salon.log_off
#puts "end of program"


