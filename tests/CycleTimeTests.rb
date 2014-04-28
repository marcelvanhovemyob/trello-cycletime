require 'test/unit'
require 'rspec-expectations'
require 'SecureRandom'
require_relative '../lib/TrelloFactory'
require_relative '../lib/TrelloCredentials'



class CycleTimeTests < Test::Unit::TestCase	
	include AgileTrello
	
	def test_user_connects_to_trello_with_public_key
		public_key = SecureRandom.uuid
		mockTrelloFactory = self
		TrelloCycleTime.new(mockTrelloFactory, public_key: public_key) 
		expect(@trello_credentials.public_key).to eql(public_key)
	end 

	def test_user_connects_to_trello_with_access_token
		access_token = SecureRandom.uuid
		mockTrelloFactory = self
		TrelloCycleTime.new(mockTrelloFactory, access_token: access_token) 
		expect(@trello_credentials.access_token).to eql(access_token)
	end 

	def test_trello_board_retrieved_by_id
		board_id = SecureRandom.uuid
		@created_trello = self
		mockTrelloFactory = self
		trello_cycle_time = TrelloCycleTime.new(mockTrelloFactory)
		trello_cycle_time.get(board_id: board_id)
		expect(@retrieved_board_id).to eql(board_id)
	end

	# def test_error_raised_when_start_list_does_not_exist
	# 	board_id = SecureRandom.uuid
	# 	board_without_start_list = {}
	# 	@created_trello = FakeTrello.new(board_id: board_id, board: board_without_start_list)
	# 	mockTrelloFactory = self
	# 	trello_cycle_time = TrelloCycleTime.new(mockTrelloFactory)
	# 	trello_cycle_time.get(board_id: board_id).should raise_error(InvalidListError, 'Invalid Start List')
	# end

	def create(trello_credentials)
		@trello_credentials = trello_credentials
		@created_trello
	end

	def get_board(board_id)
		@retrieved_board_id = board_id
	end
end

class FakeTrello
	def initialize(parameters)
		@boards = {
			parameters[:board_id] => parameters[:board]
		}
	end

	def get_board(board_id)
		@boards[board_id]
	end
end

class InvalidListError

end

module AgileTrello
	class TrelloCycleTime
		def initialize(trello_factory = TrelloFactory.new, parameters = {}) 
			trello_credentials = TrelloCredentials.new(parameters[:public_key], parameters[:access_token])
			@trello = trello_factory.create(trello_credentials) 
		end

		def get(parameters)
			@trello.get_board(parameters[:board_id])
		end
	end
end