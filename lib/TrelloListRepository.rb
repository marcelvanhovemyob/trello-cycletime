module AgileTrello
	class TrelloListRepository
		def initialize(trello)
			@trello = trello
		end

		def get(board_id)
			trello_board = @trello.get_board(board_id)
			trello_board.lists.map do |list|
				list.name
			end
		end
	end
end