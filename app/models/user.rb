class User < ActiveRecord::Base
  devise :cas_authenticatable

  validates_uniqueness_of :username
  validates_presence_of :username
end
