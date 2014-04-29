module AgileTrello
	class CardRepository
		def initialize(trello, parameters)
			@trello_board = trello.get_board(parameters[:board_id])
			@end_list = parameters[:end_list]
		end

		def get_cards_after
			cards_after = []
			@trello_board.lists.each do | list | 
				if list.name.include? (@end_list)
					list.cards.each do | card |
						cards_after.push(card)
					end
				end
			end 
			return cards_after
		end
	end
end