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

		def standard_deviation
			mean = self.average
			return 0 if mean == 0
			squared_deviations = @cycle_times.map do |cycle_time|
				(cycle_time - mean) ** 2
			end
			variance = squared_deviations.reduce(:+) / squared_deviations.length
			standard_deviation = Math.sqrt(variance)
		end
	end
end