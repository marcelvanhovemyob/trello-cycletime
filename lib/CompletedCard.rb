module AgileTrello
	class CompletedCard
		SECONDS_IN_24HRS = (24 * 60 * 60)

		attr_reader :cycle_time, :csv

		def initialize(start_date, end_date, csv)
			@cycle_time = ((end_date - start_date) / SECONDS_IN_24HRS).round(2)
			@csv = csv
		end

		def shareCycleTimeWith(calculator)
			calculator.add(@cycle_time)
		end

		def shareCardDetailsWith(reporter)
			reporter.add(@cycle_time.round(0).to_s + ","+ @csv.to_s + ",")
		end
	end
end
