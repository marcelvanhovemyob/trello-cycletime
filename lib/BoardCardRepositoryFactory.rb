require_relative './BoardCardRepository'

module AgileTrello
	class BoardCardRepositoryFactory
		def initialize(trello)
			@trello = trello
		end

		def create(board_id)
			trello_board = @trello.get_board(board_id)
			BoardCardRepository.new(trello_board)
		end
	end
end