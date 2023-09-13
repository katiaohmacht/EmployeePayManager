class User < ActiveRecord::Base
  include BCrypt

  def password
    @password ||= Password.new(password_hash)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end

  validates :email, presence: true, on: :create
  validates :email, uniqueness: true, on: :create
  has_many :reflections
  has_many :drawings
end

class Reflection < ActiveRecord::Base
  belongs_to :user
end

class Drawing < ActiveRecord::Base
  belongs_to :user
end