require_relative 'CompletedCard' 

module AgileTrello
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
end