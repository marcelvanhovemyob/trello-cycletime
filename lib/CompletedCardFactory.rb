require 'json'
require_relative 'CompletedCard'
require_relative 'CardHistory'

module AgileTrello
	class CompletedCardFactory
		MOVEMENT_ACTION_TYPE_UPDATE = 'updateCard'
		MOVEMENT_UPDATE_DATA_ATTRIBUTE = 'listAfter'
		MOVEMENT_DATA_LIST_NAME = 'name'

		def initialize(parameters)
			@start_list = parameters[:start_list]
			@end_list = parameters[:end_list]
			@all_lists = parameters[:all_lists]
			@measurement_start_date =
				parameters[:measurement_start_date].nil? ? Time.new(1066) : parameters[:measurement_start_date]
		end

		def create(trello_card)
			card_history = CardHistory.new(trello_card, @all_lists)

			start_date = card_history.find_date_entered_list(@start_list)
			end_date   = card_history.find_date_entered_list(@end_list)

			is_in_measured_period = end_date > @measurement_start_date
			#puts trello_card.short_id.to_s + "=> From "+start_date.to_s + " -> " + end_date.to_s

			if (is_in_measured_period)
				trello_card_csv = trello_card.short_id.to_s + "," + trello_card.short_url.to_s
				CompletedCard.new(start_date, end_date, trello_card_csv)
			else
				CardBeforeMeasurementPeriod.new
			end
		end
	end

	class CardBeforeMeasurementPeriod
		def shareCycleTimeWith(calculator)
		end
		def shareCardDetailsWith(reporter)
		end
	end
end
