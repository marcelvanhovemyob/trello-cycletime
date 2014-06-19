require 'peach'
require_relative './TrelloFactory'
require_relative './TrelloCredentials'
require_relative './AverageCycleTimeCalculator'
require_relative './CompletedCardRepository'
require_relative './TrelloListRepository'

module AgileTrello
	class TrelloCycleTime
		def initialize(parameters = {}) 
			trello_credentials = TrelloCredentials.new(parameters[:public_key], parameters[:access_token])
			trello_factory = parameters[:trello_factory].nil? ? TrelloFactory.new : parameters[:trello_factory]
			@trello = trello_factory.create(trello_credentials) 
			@average_cycle_time_calculator = AverageCycleTimeCalculator.new
			@trello_list_repository = TrelloListRepository.new(@trello)
		end

		def get(parameters)
			completed_card_repository = CompletedCardRepository.new(@trello, @average_cycle_time_calculator, @trello_list_repository, parameters)
			completed_card_repository.get(parameters)
			return @average_cycle_time_calculator.average
		end
	end
end