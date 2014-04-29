require 'test/unit'
require 'rspec-expectations'
require 'SecureRandom'
require_relative '../lib/TrelloFactory'
require_relative '../lib/TrelloCredentials'
require_relative '../lib/CompletedCardFactory'
require_relative '../lib/CardRepository'
require_relative '../lib/AverageCycleTimeCalculator'

class CycleTimeTests < Test::Unit::TestCase	
	include AgileTrello

	ONE_DAY = 86400

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

	def test_zero_returned_when_no_lists_on_board
		board_id = SecureRandom.uuid
		board_with_no_lists = FakeBoard.new
		@created_trello = FakeTrello.new(board_id: board_id, board: board_with_no_lists)
		mockTrelloFactory = self
		trello_cycle_time = TrelloCycleTime.new(mockTrelloFactory)
		trello_cycle_time.get(board_id: board_id).should eql(0)
	end

	def test_zero_returned_when_board_has_lists_but_no_cards
		board_id = SecureRandom.uuid
		board_with_no_cards = FakeBoard.new
		board_with_no_cards.add(FakeList.new('a list'))
		@created_trello = FakeTrello.new(board_id: board_id, board: board_with_no_cards)
		mockTrelloFactory = self
		trello_cycle_time = TrelloCycleTime.new(mockTrelloFactory)
		trello_cycle_time.get(board_id: board_id).should eql(0)
	end

	def test_cycle_time_returned_when_board_has_both_start_and_end_lists_and_card_is_in_end_list
		board_id = SecureRandom.uuid
		start_list_name = 'start list'
		end_list_name = 'end list'
		fake_card = FakeCard.new 
		today = Time.now
		two_days_ago = today - (ONE_DAY * 2)
		fake_card.add_movement(list_name: start_list_name, date: two_days_ago)
		fake_card.add_movement(list_name: end_list_name, date: today)
		board_with_start_and_end_lists = FakeBoard.new
		board_with_start_and_end_lists.add(FakeList.new(start_list_name))
		end_list = FakeList.new(end_list_name)
		end_list.add(fake_card)
		board_with_start_and_end_lists.add(end_list)
		@created_trello = FakeTrello.new(board_id: board_id, board: board_with_start_and_end_lists)
		mockTrelloFactory = self
		trello_cycle_time = TrelloCycleTime.new(mockTrelloFactory)
		trello_cycle_time.get(board_id: board_id, start_list: start_list_name, end_list: end_list_name).should eql(2.0)
	end

	def test_cycle_time_returned_rounded_to_2_decimial_places_when_board_has_both_start_and_end_lists_and_card_is_in_end_list
		board_id = SecureRandom.uuid
		start_list_name = 'start list'
		end_list_name = 'end list'
		fake_card = FakeCard.new 
		today = Time.now
		two_and_a_bit_days_ago = today - (ONE_DAY * 2.54)
		fake_card.add_movement(list_name: start_list_name, date: two_and_a_bit_days_ago)
		fake_card.add_movement(list_name: end_list_name, date: today)
		board_with_start_and_end_lists = FakeBoard.new
		board_with_start_and_end_lists.add(FakeList.new(start_list_name))
		end_list = FakeList.new(end_list_name)
		end_list.add(fake_card)
		board_with_start_and_end_lists.add(end_list)
		@created_trello = FakeTrello.new(board_id: board_id, board: board_with_start_and_end_lists)
		mockTrelloFactory = self
		trello_cycle_time = TrelloCycleTime.new(mockTrelloFactory)
		trello_cycle_time.get(board_id: board_id, start_list: start_list_name, end_list: end_list_name).should eql(2.54)
	end

	def test_average_cycle_time_of_cards_returned_when_board_has_both_start_and_end_lists_and_multiple_cards_is_in_end_list
		board_id = SecureRandom.uuid
		start_list_name = 'start list'
		end_list_name = 'end list'
		today = Time.now
		two_day_cycle_time_card = FakeCard.new 
		two_days_ago = today - (ONE_DAY * 2)
		two_day_cycle_time_card.add_movement(list_name: start_list_name, date: two_days_ago)
		two_day_cycle_time_card.add_movement(list_name: end_list_name, date: today)
		four_day_cycle_time_card = FakeCard.new 
		four_days_ago = today - (ONE_DAY * 4)
		four_day_cycle_time_card.add_movement(list_name: start_list_name, date: four_days_ago)
		four_day_cycle_time_card.add_movement(list_name: end_list_name, date: today)
		board_with_start_and_end_lists = FakeBoard.new
		board_with_start_and_end_lists.add(FakeList.new(start_list_name))
		end_list = FakeList.new(end_list_name)
		end_list.add(two_day_cycle_time_card)
		end_list.add(four_day_cycle_time_card)
		board_with_start_and_end_lists.add(end_list)
		@created_trello = FakeTrello.new(board_id: board_id, board: board_with_start_and_end_lists)
		mockTrelloFactory = self
		trello_cycle_time = TrelloCycleTime.new(mockTrelloFactory)
		trello_cycle_time.get(board_id: board_id, start_list: start_list_name, end_list: end_list_name).should eql(3.0)
	end

	def create(trello_credentials)
		@trello_credentials = trello_credentials
		@created_trello
	end

	def get_board(board_id)
		@retrieved_board_id = board_id
	end
end

class FakeBoard
	attr_reader :lists 

	def initialize 
		@lists = []
	end

	def add(list)
		@lists.push(list)
	end
end

class FakeList
	attr_reader :name, :cards

	def initialize(name)
		@name = name
		@cards = []
	end

	def add(card)
		@cards.push(card)
	end
end

class FakeCard
	attr_reader :actions

	def initialize
		@actions = []
	end

	def add_movement(parameters)
		action = FakeMovementAction.new(parameters)
		@actions.push(action)
	end
end

class FakeMovementAction 
	attr_reader :type, :data, :date

	def initialize(parameters)
		@type = 'updateCard'
		@date = parameters[:date]
		@data = {
			'listAfter' => {
				'name' => parameters[:list_name]
			}
		}
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

module AgileTrello
	class TrelloCycleTime
		def initialize(trello_factory = TrelloFactory.new, parameters = {}) 
			trello_credentials = TrelloCredentials.new(parameters[:public_key], parameters[:access_token])
			@trello = trello_factory.create(trello_credentials) 
			@average_cycle_time_calculator = AverageCycleTimeCalculator.new
		end

		def get(parameters)
			completed_card_repository = CompletedCardRepository.new(@trello, parameters)
			finished_cards = completed_card_repository.get
			finished_cards.each do |card|
				@average_cycle_time_calculator.add(card.cycle_time)
			end
			return @average_cycle_time_calculator.average
		end
	end

	class CompletedCardRepository
		def initialize(trello, parameters)
			@card_repository = CardRepository.new(trello, parameters)
			@completed_card_factory = CompletedCardFactory.new(start_list: parameters[:start_list], end_list: parameters[:end_list])
		end

		def get
			completed_cards = @card_repository.get_cards_after
			completed_cards.map do |card|
				@completed_card_factory.create(card)
			end
		end
	end
end