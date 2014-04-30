require_relative 'CompletedCard' 
require_relative 'CardHistory'

module AgileTrello
	class CompletedCardFactory
		MOVEMENT_ACTION_TYPE = 'updateCard'
		MOVEMENT_DATA_ATTRIBUTE = 'listAfter'
		MOVEMENT_DATA_LIST_NAME = 'name'

		def initialize(parameters)
			@start_list = parameters[:start_list]
			@end_list = parameters[:end_list]
			@all_lists = parameters[:all_lists]
		end

		def create(trello_card)
			card_history = CardHistory.new(trello_card, @all_lists)
			start_date = card_history.find_date_entered_list(@start_list)
			end_date = card_history.find_date_entered_list(@end_list)
			CompletedCard.new(start_date, end_date)
		end
	end
end