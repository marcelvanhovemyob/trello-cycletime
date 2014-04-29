require_relative './TrelloFactory'
require_relative './TrelloCredentials'
require_relative './AverageCycleTimeCalculator'
require_relative './CompletedCardRepository'

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
			finished_cards.each do | card |
				@average_cycle_time_calculator.add(card.cycle_time)
			end
			return @average_cycle_time_calculator.average
		end
	end
end