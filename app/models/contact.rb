class Contact < ActiveRecord::Base
	belongs_to :account

	validates :account, :presence => true

	attr_accessible :account_id, :padma_id
end
