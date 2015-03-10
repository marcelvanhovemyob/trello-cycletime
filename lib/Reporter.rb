module AgileTrello
  class Reporter
    def initialize
      @report = []
    end
    def add(reporting_line)
      @report.push(reporting_line)
    end
    def report
      s = ""
      @report.each do |line|
        s += line + 10.chr
      end
      return s
    end
  end
end
