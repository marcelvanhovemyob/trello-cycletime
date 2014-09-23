require 'TrelloFactory'
require 'TrelloCredentials'
require_relative './AverageCycleTimeCalculator'
require_relative './StandardDeviationCalculator'
require_relative './CompletedCards'
require_relative './TrelloListRepository'

module AgileTrello
	class TrelloCycleTime
		def initialize(parameters = {}) 
			trello_credentials = TrelloCredentials.new(parameters[:public_key], parameters[:access_token])
			trello_factory = parameters[:trello_factory].nil? ? TrelloFactory.new : parameters[:trello_factory]
			trello = trello_factory.create(trello_credentials) 
			@average_cycle_time_calculator = AverageCycleTimeCalculator.new
			@standard_deviation_calculator = StandardDeviationCalculator.new(@average_cycle_time_calculator)
			@completed_cards = CompletedCards.new(trello, @standard_deviation_calculator, TrelloListRepository.new(trello))
		end

		def get(parameters)
			@completed_cards.retrieve(parameters)
			return CycleTime.new(@average_cycle_time_calculator.average, @standard_deviation_calculator.standard_deviation)
		end
	end

	class CycleTime 
		attr_reader :mean, :standard_deviation

		def initialize(mean, standard_deviation)
			@mean = mean
			@standard_deviation = standard_deviation
		end
	end
end