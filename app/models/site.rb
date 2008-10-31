class Site < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_many :pages
  
  def allow_access_for(user)
    user.admin? || self.users.include?(user)
  end
  
  def homepage
    self.pages.find(:first,:conditions => {:parent_id => nil})
  end
end
