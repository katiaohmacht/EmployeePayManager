class User < ActiveRecord::Base
  include BCrypt

  def password
    @password ||= Password.new(password_hash)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end
  validates :employee_id, presence: true, on: :create
  validates :employee_id, uniqueness: true, on: :create

end

class Checktime < ActiveRecord::Base
end

class Payperiod < ActiveRecord::Base 
end