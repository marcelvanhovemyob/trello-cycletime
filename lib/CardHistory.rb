module AgileTrello
	class CardHistory
		MOVEMENT_ACTION_TYPE = 'updateCard'
		MOVEMENT_DATA_ATTRIBUTE = 'listAfter'
		MOVEMENT_DATA_LIST_NAME = 'name'

		def initialize(trello_card, all_lists_on_board)
			@card_movements = trello_card.actions.select do | action |
				action.type == MOVEMENT_ACTION_TYPE && !action.data[MOVEMENT_DATA_ATTRIBUTE].nil?
			end
			@all_lists_on_board = all_lists_on_board
		end

		def find_date_entered_list(list_name)
			@card_movements.each do |movement|
				return movement.date if movement.data[MOVEMENT_DATA_ATTRIBUTE][MOVEMENT_DATA_LIST_NAME].include?(list_name)
			end
			current_index = @all_lists_on_board.index { |board_list_name| board_list_name.include? list_name }
			next_list_name = @all_lists_on_board[current_index + 1]
			find_date_entered_list(next_list_name)
		end
	end
end