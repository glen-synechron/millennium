class Service < ActiveRecord::Base
  attr_accessible :price, :service_class, :service_id, :service_sub_class, :start_length, :gap_length, :finish_length
end
