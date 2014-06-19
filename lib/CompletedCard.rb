module AgileTrello
	class CompletedCard
		SECONDS_IN_24HRS = (24 * 60 * 60)

		attr_reader :cycle_time

		def initialize(start_date, end_date)
			@cycle_time = ((end_date - start_date) / SECONDS_IN_24HRS).round(2)
		end

		def shareCycleTimeWith(calculator)
			calculator.add(@cycle_time)
		end
	end
end