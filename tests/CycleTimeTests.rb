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
		fake_card.add_movement(list_name: start_list_name, date: Time.new(2002, 10, 01))
		fake_card.add_movement(list_name: end_list_name, date: Time.new(2002, 10, 03))
		board_with_start_and_end_lists = FakeBoard.new
		board_with_start_and_end_lists.add(FakeList.new('start list'))
		end_list = FakeList.new('end list')
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
		fake_card.add_movement(list_name: start_list_name, date: Time.new(2002, 10, 01, '11:00'))
		fake_card.add_movement(list_name: end_list_name, date: Time.new(2002, 10, 03))
		board_with_start_and_end_lists = FakeBoard.new
		board_with_start_and_end_lists.add(FakeList.new('start list'))
		end_list = FakeList.new('end list')
		end_list.add(fake_card)
		board_with_start_and_end_lists.add(end_list)
		@created_trello = FakeTrello.new(board_id: board_id, board: board_with_start_and_end_lists)
		mockTrelloFactory = self
		trello_cycle_time = TrelloCycleTime.new(mockTrelloFactory)
		trello_cycle_time.get(board_id: board_id, start_list: start_list_name, end_list: end_list_name).should eql(1.54)
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

class InvalidListError

end

module AgileTrello
	class TrelloCycleTime
		def initialize(trello_factory = TrelloFactory.new, parameters = {}) 
			trello_credentials = TrelloCredentials.new(parameters[:public_key], parameters[:access_token])
			@trello = trello_factory.create(trello_credentials) 
		end

		def get(parameters)
			completed_card_repository = CompletedCardRepository.new(@trello, parameters)
			finished_cards = completed_card_repository.get
			return 0 if finished_cards.length == 0
			return finished_cards[0].cycle_time
		end
	end

	class CompletedCardRepository
		def initialize(trello, parameters)
			@card_repository = CardRepository.new(trello, parameters)
			@completed_card_factory = CompletedCardFactory.new(start_list: parameters[:start_list], end_list: parameters[:end_list])
		end

		def get
			completed_cards = @card_repository.get_cards_after
			return [] if completed_cards.length == 0
			completed_card = @completed_card_factory.create(completed_cards[0])
			[completed_card]
		end
	end

	class CompletedCardFactory
		MOVEMENT_ACTION_TYPE = 'updateCard'
		MOVEMENT_DATA_ATTRIBUTE = 'listAfter'
		MOVEMENT_DATA_LIST_NAME = 'name'

		def initialize(parameters)
			@start_list = parameters[:start_list]
			@end_list = parameters[:end_list]
		end

		def create(trello_card)
			card_movements = trello_card.actions.select do | action |
				action.type == MOVEMENT_ACTION_TYPE && !action.data[MOVEMENT_DATA_ATTRIBUTE].nil?
			end

			start_date = nil
			end_date = nil
			card_movements.each do |movement|
				start_date = movement.date if movement.data[MOVEMENT_DATA_ATTRIBUTE][MOVEMENT_DATA_LIST_NAME].include?(@start_list)
				end_date = movement.date if movement.data[MOVEMENT_DATA_ATTRIBUTE][MOVEMENT_DATA_LIST_NAME].include?(@end_list)
			end

			CompletedCard.new(start_date, end_date)
		end
	end

	class CompletedCard
		SECONDS_IN_24HRS = (24 * 60 * 60)

		attr_reader :cycle_time

		def initialize(start_date, end_date)
			@cycle_time = ((end_date - start_date) / SECONDS_IN_24HRS).round(2)
		end
	end

	class CardRepository
		def initialize(trello, parameters)
			@trello_board = trello.get_board(parameters[:board_id])
		end

		def get_cards_after
			cards_after = []
			@trello_board.lists.each do | list | 
				list.cards.each do | card |
					cards_after.push(card)
				end
			end 
			return cards_after
		end
	end
end