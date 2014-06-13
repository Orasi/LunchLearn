class User < ActiveRecord::Base


  validates :username, presence: true, uniqueness: {case_sensitive: false}
  validates :first_name, :last_name, presence: true
  validates :admin, presence: true 

  def display_name
    self.first_name.capitalize + " " + self.last_name.capitalize
  end


end
