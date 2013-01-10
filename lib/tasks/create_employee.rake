namespace :add_details  do
  desc "Add details to local database"
  task add_employees: :environment do
    if Employee.first.blank?
      salon = Salon.first
      employees = salon.get_employee_listing({})
      Employee.create!(employees)
    end
  end
  desc "Add details to local database"
  task add_services: :environment do
    if Service.first.blank?
      salon = Salon.first
      services = salon.get_service_listing({})
      services.each do |service|
        Service.create!(service.merge({finish_length: "1"}))
      end     
    end
  end
end