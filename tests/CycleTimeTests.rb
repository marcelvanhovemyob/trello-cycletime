require 'test/unit'
require 'rspec-expectations'
require_relative '../lib/TrelloCycleTime'

class CycleTimeTests < Test::Unit::TestCase	
	include AgileTrello

	ONE_DAY = 86400

	def test_user_connects_to_trello_with_public_key
		public_key = SecureRandom.uuid
		mockTrelloFactory = self
		TrelloCycleTime.new(trello_factory: mockTrelloFactory, public_key: public_key) 
		expect(@trello_credentials.public_key).to eql(public_key)
	end 

	def test_user_connects_to_trello_with_access_token
		access_token = SecureRandom.uuid
		mockTrelloFactory = self
		TrelloCycleTime.new(trello_factory: mockTrelloFactory, access_token: access_token) 
		expect(@trello_credentials.access_token).to eql(access_token)
	end 

	def test_zero_returned_when_no_lists_on_board
		board_id = SecureRandom.uuid
		board_with_no_lists = FakeBoard.new
		@created_trello = FakeTrello.new(board_id: board_id, board: board_with_no_lists)
		mockTrelloFactory = self
		trello_cycle_time = TrelloCycleTime.new(trello_factory: mockTrelloFactory)
		trello_cycle_time.get(board_id: board_id).mean.should eql(0)
	end

	def test_zero_returned_when_board_has_lists_but_no_cards
		board_id = SecureRandom.uuid
		board_with_no_cards = FakeBoard.new
		board_with_no_cards.add(FakeList.new('a list'))
		@created_trello = FakeTrello.new(board_id: board_id, board: board_with_no_cards)
		mockTrelloFactory = self
		trello_cycle_time = TrelloCycleTime.new(trello_factory: mockTrelloFactory)
		trello_cycle_time.get(board_id: board_id, end_list: '').mean.should eql(0)
	end

	def test_cycle_time_returned_when_board_has_both_start_and_end_lists_and_card_is_in_end_list
		board_id = SecureRandom.uuid
		start_list_name = 'start list'
		end_list_name = 'end list'
		board_with_start_and_end_lists = FakeBoard.new
		board_with_start_and_end_lists.add(FakeList.new(start_list_name))
		end_list = FakeList.new(end_list_name)
		fake_card = FakeCardBuilder.create
			.moved_to(start_list_name).days_ago(2)
			.moved_to(end_list_name).today
			.build
		end_list.add(fake_card)
		board_with_start_and_end_lists.add(end_list)
		@created_trello = FakeTrello.new(board_id: board_id, board: board_with_start_and_end_lists)
		mockTrelloFactory = self
		trello_cycle_time = TrelloCycleTime.new(trello_factory: mockTrelloFactory)
		trello_cycle_time.get(board_id: board_id, start_list: start_list_name, end_list: end_list_name).mean.should eql(2.0)
	end

	def test_cycle_time_returned_rounded_to_2_decimial_places_when_board_has_both_start_and_end_lists_and_card_is_in_end_list
		board_id = SecureRandom.uuid
		start_list_name = 'start list'
		end_list_name = 'end list'
		board_with_start_and_end_lists = FakeBoard.new
		board_with_start_and_end_lists.add(FakeList.new(start_list_name))
		end_list = FakeList.new(end_list_name)
		fake_card = FakeCardBuilder.create
			.moved_to(start_list_name).days_ago(2.54)
			.moved_to(end_list_name).today
			.build
		end_list.add(fake_card)
		board_with_start_and_end_lists.add(end_list)
		@created_trello = FakeTrello.new(board_id: board_id, board: board_with_start_and_end_lists)
		mockTrelloFactory = self
		trello_cycle_time = TrelloCycleTime.new(trello_factory: mockTrelloFactory)
		trello_cycle_time.get(board_id: board_id, start_list: start_list_name, end_list: end_list_name).mean.should eql(2.54)
	end

	def test_cycle_time_returned_rounded_to_2_decimial_places_when_board_has_multiple_cards_with_odd_times
		board_id = SecureRandom.uuid
		start_list_name = 'start list'
		end_list_name = 'end list'
		board_with_start_and_end_lists = FakeBoard.new
		board_with_start_and_end_lists.add(FakeList.new(start_list_name))
		end_list = FakeList.new(end_list_name)
		odd_card_one = FakeCardBuilder.create
			.moved_to(start_list_name).days_ago(2.5411111)
			.moved_to(end_list_name).today
			.build
		odd_card_two = FakeCardBuilder.create
			.moved_to(start_list_name).days_ago(3.94234234)
			.moved_to(end_list_name).today
			.build
		end_list.add(odd_card_one)
		end_list.add(odd_card_two)
		board_with_start_and_end_lists.add(end_list)
		@created_trello = FakeTrello.new(board_id: board_id, board: board_with_start_and_end_lists)
		mockTrelloFactory = self
		trello_cycle_time = TrelloCycleTime.new(trello_factory: mockTrelloFactory)
		trello_cycle_time.get(board_id: board_id, start_list: start_list_name, end_list: end_list_name).mean.should eql(3.24)
	end

	def test_average_cycle_time_of_cards_returned_when_board_has_both_start_and_end_lists_and_multiple_cards_is_in_end_list
		board_id = SecureRandom.uuid
		start_list_name = 'start list'
		end_list_name = 'end list'
		board_with_start_and_end_lists = FakeBoard.new
		board_with_start_and_end_lists.add(FakeList.new(start_list_name))
		end_list = FakeList.new(end_list_name)
		two_day_cycle_time_card = FakeCardBuilder.create
			.moved_to(start_list_name).days_ago(2)
			.moved_to(end_list_name).today
			.build
		four_day_cycle_time_card = FakeCardBuilder.create
			.moved_to(start_list_name).days_ago(4)
			.moved_to(end_list_name).today
			.build
		end_list.add(two_day_cycle_time_card)
		end_list.add(four_day_cycle_time_card)
		board_with_start_and_end_lists.add(end_list)
		@created_trello = FakeTrello.new(board_id: board_id, board: board_with_start_and_end_lists)
		mockTrelloFactory = self
		trello_cycle_time = TrelloCycleTime.new(trello_factory: mockTrelloFactory)
		trello_cycle_time.get(board_id: board_id, start_list: start_list_name, end_list: end_list_name).mean.should eql(3.0)
	end

	def test_average_cycle_time_of_cards_returned_does_not_include_those_before_end_list
		board_id = SecureRandom.uuid
		start_list_name = 'start list'
		end_list_name = 'end list'
		board_with_start_and_end_lists = FakeBoard.new
		start_list = FakeList.new(start_list_name)
		two_day_cycle_time_card = FakeCardBuilder.create
			.moved_to(start_list_name).days_ago(2)
			.moved_to(end_list_name).today
			.build
		start_list.add(two_day_cycle_time_card)
		board_with_start_and_end_lists.add(start_list)
		end_list = FakeList.new(end_list_name)
		four_day_cycle_time_card = FakeCardBuilder.create
			.moved_to(start_list_name).days_ago(4)
			.moved_to(end_list_name).today
			.build
		end_list.add(four_day_cycle_time_card)
		board_with_start_and_end_lists.add(end_list)
		@created_trello = FakeTrello.new(board_id: board_id, board: board_with_start_and_end_lists)
		mockTrelloFactory = self
		trello_cycle_time = TrelloCycleTime.new(trello_factory: mockTrelloFactory)
		trello_cycle_time.get(board_id: board_id, start_list: start_list_name, end_list: end_list_name).mean.should eql(4.0)
	end

	def test_average_cycle_time_of_cards_returned_does_include_those_after_end_list
		board_id = SecureRandom.uuid
		start_list_name = 'start list'
		end_list_name = 'end list'
		board_with_list_after_end_list = FakeBoard.new
		board_with_list_after_end_list.add(FakeList.new(start_list_name))
		end_list = FakeList.new(end_list_name)
		four_day_cycle_time_card = FakeCardBuilder.create
			.moved_to(start_list_name).days_ago(4)
			.moved_to(end_list_name).today
			.build
		end_list.add(four_day_cycle_time_card)
		board_with_list_after_end_list.add(end_list)
		after_list = FakeList.new('after list')
		two_day_cycle_time_card = FakeCardBuilder.create
			.moved_to(start_list_name).days_ago(2)
			.moved_to(end_list_name).today
			.build
		after_list.add(two_day_cycle_time_card)
		board_with_list_after_end_list.add(after_list)
		@created_trello = FakeTrello.new(board_id: board_id, board: board_with_list_after_end_list)
		mockTrelloFactory = self
		trello_cycle_time = TrelloCycleTime.new(trello_factory: mockTrelloFactory)
		trello_cycle_time.get(board_id: board_id, start_list: start_list_name, end_list: end_list_name).mean.should eql(3.0)
	end

	def test_average_cycle_time_of_cards_returned_includes_those_that_skipped_start_list
		board_id = SecureRandom.uuid
		start_list_name = 'start list'
		end_list_name = 'end list'
		board_with_list_after_end_list = FakeBoard.new
		board_with_list_after_end_list.add(FakeList.new(start_list_name))
		middle_list = FakeList.new('middle list')
		board_with_list_after_end_list.add(middle_list)
		end_list = FakeList.new(end_list_name)
		two_day_card_skipped_start_list = FakeCardBuilder.create
			.moved_to(start_list_name).days_ago(2)
			.moved_to(end_list_name).today
			.build
		end_list.add(two_day_card_skipped_start_list)
		four_day_cycle_time_card = FakeCardBuilder.create
			.moved_to(start_list_name).days_ago(4)
			.moved_to(end_list_name).today
			.build
		end_list.add(four_day_cycle_time_card)
		board_with_list_after_end_list.add(end_list)
		@created_trello = FakeTrello.new(board_id: board_id, board: board_with_list_after_end_list)
		mockTrelloFactory = self
		trello_cycle_time = TrelloCycleTime.new(trello_factory: mockTrelloFactory)
		trello_cycle_time.get(board_id: board_id, start_list: start_list_name, end_list: end_list_name).mean.should eql(3.0)
	end

	def test_when_measurement_start_date_specified_then_calculation_does_not_include_cards_that_entered_the_end_list_before_the_start_of_measurement_date
		board_id = SecureRandom.uuid
		start_list_name = 'start list'
		end_list_name = 'end list'
		board_with_start_and_end_lists = FakeBoard.new
		board_with_start_and_end_lists.add(FakeList.new(start_list_name))
		end_list = FakeList.new(end_list_name)
		card_inside_period = FakeCardBuilder.create
			.moved_to(start_list_name).days_ago(2)
			.moved_to(end_list_name).today
			.build
		card_outside_period = FakeCardBuilder.create
			.moved_to(start_list_name).days_ago(6)
			.moved_to(end_list_name).days_ago(5)
			.build
		end_list.add(card_inside_period)
		end_list.add(card_outside_period)
		board_with_start_and_end_lists.add(end_list)
		@created_trello = FakeTrello.new(board_id: board_id, board: board_with_start_and_end_lists)
		mockTrelloFactory = self
		trello_cycle_time = TrelloCycleTime.new(trello_factory: mockTrelloFactory)
		four_days_ago = Time.now - (ONE_DAY * 4)
		trello_cycle_time.get(board_id: board_id, start_list: start_list_name, end_list: end_list_name, measurement_start_date: four_days_ago).mean.should eql(2.0)
	end

	def test_two_cards_with_same_cycle_time_results_in_standard_deviation_of_0
		board_id = SecureRandom.uuid
		start_list_name = 'start list'
		end_list_name = 'end list'
		board_with_start_and_end_lists = FakeBoard.new
		board_with_start_and_end_lists.add(FakeList.new(start_list_name))
		end_list = FakeList.new(end_list_name)
		fake_card1 = FakeCardBuilder.create
			.moved_to(start_list_name).days_ago(2)
			.moved_to(end_list_name).today
			.build
		fake_card2 = FakeCardBuilder.create
			.moved_to(start_list_name).days_ago(4)
			.moved_to(end_list_name).days_ago(2)
			.build
		end_list.add(fake_card1)
		end_list.add(fake_card2)
		board_with_start_and_end_lists.add(end_list)
		@created_trello = FakeTrello.new(board_id: board_id, board: board_with_start_and_end_lists)
		mockTrelloFactory = self
		trello_cycle_time = TrelloCycleTime.new(trello_factory: mockTrelloFactory)
		cycle_time = trello_cycle_time.get(board_id: board_id, start_list: start_list_name, end_list: end_list_name)
		cycle_time.standard_deviation.should eql(0.0)
	end

	def test_when_one_card_cycle_time_of_2_And_one_card_cycle_time_of_4_Then_standard_deviation_of_1
		board_id = SecureRandom.uuid
		start_list_name = 'start list'
		end_list_name = 'end list'
		board_with_start_and_end_lists = FakeBoard.new
		board_with_start_and_end_lists.add(FakeList.new(start_list_name))
		end_list = FakeList.new(end_list_name)
		fake_card1 = FakeCardBuilder.create
			.moved_to(start_list_name).days_ago(2)
			.moved_to(end_list_name).today
			.build
		fake_card2 = FakeCardBuilder.create
			.moved_to(start_list_name).days_ago(6)
			.moved_to(end_list_name).days_ago(2)
			.build
		end_list.add(fake_card1)
		end_list.add(fake_card2)
		board_with_start_and_end_lists.add(end_list)
		@created_trello = FakeTrello.new(board_id: board_id, board: board_with_start_and_end_lists)
		mockTrelloFactory = self
		trello_cycle_time = TrelloCycleTime.new(trello_factory: mockTrelloFactory)
		cycle_time = trello_cycle_time.get(board_id: board_id, start_list: start_list_name, end_list: end_list_name)
		cycle_time.standard_deviation.should eql(1.0)
	end

	def create(trello_credentials)
		@trello_credentials = trello_credentials
		@created_trello
	end

	def get_board(board_id)
		@retrieved_board_id = board_id
	end
end

class FakeCardBuilder
	ONE_DAY = 86400

	def initialize
		@fake_card = FakeCard.new 
	end

	def self.create 
		FakeCardBuilder.new
	end

	def moved_to(list_name)
		return MovementBuilder.new(self, @fake_card, list_name)
	end

	def build
		@fake_card
	end

	class MovementBuilder
		def initialize(fake_card_builder, fake_card, list_name)
			@fake_card_builder = fake_card_builder
			@fake_card = fake_card
			@list_name = list_name
			@todays_date = Time.now
		end

		def today
			@fake_card.add_movement(list_name: @list_name, date: @todays_date)
			return @fake_card_builder
		end

		def days_ago(days)
			date = @todays_date - (ONE_DAY * days)
			@fake_card.add_movement(list_name: @list_name, date: date)
			return @fake_card_builder
		end
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