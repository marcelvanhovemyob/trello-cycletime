module AgileTrello
	class CardHistory
		MOVEMENT_ACTION_TYPE = 'updateCard'
		MOVEMENT_DATA_ATTRIBUTE = 'listAfter'
		MOVEMENT_DATA_LIST_NAME = 'name'

		def initialize(trello_card)
			@card_movements = trello_card.actions.select do | action |
				action.type == MOVEMENT_ACTION_TYPE && !action.data[MOVEMENT_DATA_ATTRIBUTE].nil?
			end
		end

		def find_date_entered_list(list_name)
			@card_movements.each do |movement|
				return movement.date if movement.data[MOVEMENT_DATA_ATTRIBUTE][MOVEMENT_DATA_LIST_NAME].include?(list_name)
			end
		end
	end
end