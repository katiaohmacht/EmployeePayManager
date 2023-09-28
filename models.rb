 #Creator: Penelope Brody, Katia Omacht, Ewan Ward
  #Teacher: Mr. Crute
  #Description: Create models page with ruby
  #Date Created: September 15th, 2023
  #Date Last Modified: September 27th, 2023

class User < ActiveRecord::Base
  include BCrypt
  #define password
  def password
    @password ||= Password.new(password_hash)
  end
  #Create password hash
  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end
  #Validate employee ID is unique and exists
  validates :employee_id, presence: true, on: :create
  validates :employee_id, uniqueness: true, on: :create

end

# Check times for employees
class Checktime < ActiveRecord::Base
end

# Pay period for employees
class Payperiod < ActiveRecord::Base 
end