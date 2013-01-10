# When making any request to the Millennium SDK (except the 'logon' request) a 'session id' needs to be sent within the header.
# This is as per requirements of the Millennium SDK.
# Hence a logon is required prior to sending the actual request.
# I have not been able to find out when the session id expires.
# At the end of the code I also send the log_off request to terminate the session

# Methods written so far
# logon
# get_all_appointments_by_date
# get_appointment
# put_appointment
# get_client_info_by_email
# put_client
# log_off

# Extra methods written
# get_employee_listing

require 'rubygems'
# At the time of writing this, the latest version of Savon is 2.0.2
# The code I wrote worked with Savon 1.2.0. There are major changes between Savon 1.2.0 and 2.0.2
# Hence I am using 1.2.0 only for now.
require 'savon'
#require 'ruby-debug'
class Millennium
  ############################### Initial configuration ##################################################################
  # Constants used across all method requests
  $server = 'http://ec2-23-22-112-83.compute-1.amazonaws.com/MillenniumSDK/millenniumsdk.asmx?WSDL'
  $guid = "2282590F-B094-7FA1-5132-51667C35D70E"
  $user = 'sdktest'
  $password = 'sdk1234*'
  $xmlns = "http://www.harms-software.com/Millennium.SDK"

  Savon.configure do |c|
    c.env_namespace = :soap
  end

  $client = Savon::Client.new do |wsdl|
    wsdl.document = 'http://ec2-23-22-112-83.compute-1.amazonaws.com/MillenniumSDK/millenniumsdk.asmx?WSDL'
  end


  ######################################## logon method #################################################################
  # logon method => notice there is no session_id in the Header
  def self.login_to_api
    response = $client.request(:logon, {:xmlns => $xmlns }) do
      soap.header = {
        'MillenniumInfo' => {'MillenniumGuid' => $guid},
        :attributes! => {"MillenniumInfo" => {:xmlns => $xmlns } }
      }
      soap.body = {'User' => $user, 'Password' => $password}
    end
    $session_id = response.header[:session_info][:session_id]
    # Checking the response of the login method to see if correct
    unless response.body[:logon_response][:logon_result]
      puts "Logon incorrect"
      exit
    else
      puts "CCCCCCCCCCCCCCCCCCCCCCCCCCCCCC"
      puts "CCCCCCCCCCCCCCCCCCCCCCCCCCCCCC"
      puts $session_id
      puts "CCCCCCCCCCCCCCCCCCCCCCCCCCCCCC"
      puts "CCCCCCCCCCCCCCCCCCCCCCCCCCCCCC"
    end
  end

  def self.fetch_all_appointments
    ################################ get_all_appointments_by_date method ##################################################
    # get_all_appointments_by_date => session_id is now added to the Header
    response = $client.request(:get_all_appointments_by_date, {:xmlns => $xmlns}) do
      soap.header = {
        'MillenniumInfo' => {'MillenniumGuid' => $guid},
        'SessionInfo' => {'SessionId' => $session_id},
        :attributes! => {"SessionInfo" => {:xmlns => $xmlns}, "MillenniumInfo" => {:xmlns => $xmlns}  }
      }
      # Change the values of StartDate and EndDate, they are just for today and today + 2 days hence.
      # the method .xmlschema gets the date in the required format for SOAP
      soap.body = {
        'StartDate' => DateTime.now.xmlschema,
        'EndDate' => (DateTime.now + 2).xmlschema
      }
    end
    # the spelling for the key in the response is 'apptointments' this is not a typo from my end but from the response. WTF?
    Nori.parse(response.body[:get_all_appointments_by_date_response][:get_all_appointments_by_date_result])[:get_all_apptointments_by_date][:apptointments].each do |appointment|
      puts "-----------------"
      puts appointment
      puts "-----------------"
    end
  end

  def self.create_appointment
    response = $client.request(:put_appointment, {:xmlns => $xmlns }) do
      soap.header = {
        'MillenniumInfo' => {'MillenniumGuid' => $guid},
        'SessionInfo' => {'SessionId' => $session_id},
        :attributes! => {"SessionInfo" => {:xmlns => $xmlns}, "MillenniumInfo" => {:xmlns => $xmlns}  }
      }
      soap.body = {
        'Appointment' => {
          'AppointmentDetails' => {
            'AppointmentDetail' => {
              'StartTime' => '1130',
              'EmployeeId' => 3,
              'ClientId' => 6,
              'ServiceId' => 2,
              'StartLength' => 0.5,
              'GapLength' => 0,
              'FinishLength' => 0,
              'AppointmentType' => 5,
              'ResourceId' => 0
            }
          },
          'PayingClientId' => 3,
          'Notes' => 'Booked VIA the SDK',
          'AppointmentDate' => Date.today + 6,
          'CategoryId' => -12
        }
      }
    end

    appointment_id = response.body[:put_appointment_response][:put_appointment_result]
    puts "*"*23
    puts appointment_id
    puts "*"*23
  end

  def self.fetch_all_employees
    response = $client.request(:get_employee_listing, {:xmlns => $xmlns }) do
      soap.header = {
        'MillenniumInfo' => {'MillenniumGuid' => $guid},
        'SessionInfo' => {'SessionId' => $session_id},
        :attributes! => {"SessionInfo" => {:xmlns => $xmlns},
          "MillenniumInfo" => {:xmlns => $xmlns}  }
      }

      soap.body = {'IncludeDeleted' => true, 'IncludeInactive' => true}
    end

  end

end