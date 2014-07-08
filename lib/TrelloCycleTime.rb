require_relative './TrelloFactory'
require_relative './TrelloCredentials'
require_relative './AverageCycleTimeCalculator'
require_relative './CompletedCards'
require_relative './TrelloListRepository'

module AgileTrello
	class TrelloCycleTime
		def initialize(parameters = {}) 
			trello_credentials = TrelloCredentials.new(parameters[:public_key], parameters[:access_token])
			trello_factory = parameters[:trello_factory].nil? ? TrelloFactory.new : parameters[:trello_factory]
			trello = trello_factory.create(trello_credentials) 
			@average_cycle_time_calculator = AverageCycleTimeCalculator.new
			@completed_cards = CompletedCards.new(trello, @average_cycle_time_calculator, TrelloListRepository.new(trello))
		end

		def get(parameters)
			@completed_cards.retrieve(parameters)
			return BoardCycleTime.new(@average_cycle_time_calculator.average)
		end
	end

	class BoardCycleTime 
		attr_reader :cycle_time

		def initialize(cycle_time)
			@cycle_time = cycle_time
		end
	end
end