require 'test/unit'
require 'rspec-expectations'
require 'SecureRandom'

class CycleTimeTests < Test::Unit::TestCase	
	def test_user_connects_to_trello_with_public_key
		public_key = SecureRandom.uuid
		mockTrelloFactory = self
		TrelloCycleTime.new(public_key, mockTrelloFactory) 
		expect(@trello_credentials.public_key).to eql(public_key)
	end 

	def create(trello_credentials)
		@trello_credentials = trello_credentials
	end
end

class TrelloCycleTime
	def initialize(public_key, trello_factory) 
		trello_credentials = TrelloCredentials.new(public_key)
		trello_factory.create(trello_credentials) 
	end
end

class TrelloCredentials 
	attr_reader :public_key

	def initialize(public_key)
		@public_key = public_key
	end
end