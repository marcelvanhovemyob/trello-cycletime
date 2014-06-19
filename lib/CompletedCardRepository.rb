require_relative './CompletedCardFactory'
require_relative './BoardCardRepositoryFactory'

module AgileTrello
	class CompletedCardRepository
		def initialize(trello, average_cycle_time_calculator, trello_list_repository, parameters)
			@board_card_repository_factory = BoardCardRepositoryFactory.new(trello)
			@trello_list_repository = trello_list_repository
			@average_cycle_time_calculator = average_cycle_time_calculator
		end

		def get(parameters)
			board_id = parameters[:board_id]
			end_list = parameters[:end_list]

			completed_card_for_board_factory = CompletedCardFactory.new(
				start_list: parameters[:start_list], 
				end_list: end_list,
				all_lists: @trello_list_repository.get(board_id),
			)
			@board_card_repository_factory
				.create(board_id)
				.get_cards_after(end_list)
				.each do |card|
					completed_card_for_board_factory
						.create(card)
						.shareCycleTimeWith(@average_cycle_time_calculator)
				end
		end
	end
end