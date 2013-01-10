class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :fetch_salon, :fetch_services, :fetch_employees

  private
  def fetch_salon
    @salon = Salon.first
  end

  def fetch_services
    @services = Service.all.collect{|service| [service.service_class, service.service_id]}.uniq
  end

  def fetch_employees
    @employees = Employee.all.collect{|employee| [employee.name, employee.employee_id]}
  end
end
