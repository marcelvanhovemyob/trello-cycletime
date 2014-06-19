module AgileTrello
	class BoardCardRepository
		def initialize(trello_board)
			@trello_board = trello_board
		end

		def get_cards_after(end_list)
			cards_after = []
			ignore = true
			@trello_board.lists.each do | list | 
				ignore = !list.name.include?(end_list) if ignore
				if !ignore
					list.cards.each do | card |
						cards_after.push(card)
					end
				end
			end 
			return cards_after
		end
	end
end