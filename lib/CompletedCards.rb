require_relative './CompletedCardFactory'
require_relative './BoardCardRepositoryFactory'

module AgileTrello

	class CompletedCards
		def initialize(trello, cycle_time_store, trello_list_repository, reporter)
			@board_card_repository_factory = BoardCardRepositoryFactory.new(trello)
			@trello_list_repository = trello_list_repository
			@cycle_time_store = cycle_time_store
			@reporter = reporter
		end

		def retrieve(parameters)
			board_id = parameters[:board_id]
			end_list = parameters[:end_list]

			completed_card_for_board_factory = CompletedCardFactory.new(
				start_list: parameters[:start_list],
				end_list: end_list,
				all_lists: @trello_list_repository.get(board_id),
				measurement_start_date: parameters[:measurement_start_date]
			)

			board_card_repository = @board_card_repository_factory.create(board_id)

			list_of_cards = board_card_repository.get_cards_after(end_list)
			list_of_cards.each do |card|
					completed_card = completed_card_for_board_factory.create(card)
					completed_card.shareCycleTimeWith(@cycle_time_store)
				  completed_card.shareCardDetailsWith(@reporter)
			end
		end
	end
end
