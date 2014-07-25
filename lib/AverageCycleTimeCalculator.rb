module AgileTrello
	class AverageCycleTimeCalculator
		def initialize
			@cycle_times = []
		end

		def add(cycle_time)
			@cycle_times.push(cycle_time)
		end

		def average
			return 0 if @cycle_times.length == 0
			(@cycle_times.reduce(:+) / @cycle_times.length).round(2)
		end
	end
end