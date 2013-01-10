class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :client_id, :first_name, :last_name, :email, :password, :password_confirmation, :remember_me
  # attr_accessible :title, :body
  validates :first_name, :last_name, presence: true
  validates :email, uniqueness: {case_sensitive: false}

  def create_client(salon)
    response = salon.get_client_info_by_email({email: self.email})
    if response.blank?
      begin
        response = salon.put_client({'client' => {
              'LastName' => self.last_name,
              'FirstName' => self.first_name,
              'ReferralTypeId' => 4,
              'EmailAddress' => self.email
            }})
        self.update_attributes(client_id: response[:client_id].to_i)
      rescue
      end
    else
      self.update_attributes(client_id: response[:client_id].to_i)
    end
  end
end
