class Salon < ActiveRecord::Base
  attr_accessible :end_time, :guid, :password, :server, :session_id, :start_time, :string, :user
  require 'millennium'
  include Millennium
end
