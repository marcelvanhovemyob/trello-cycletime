require 'C:\_projects\trello-cycletime\lib\TrelloCycleTime.rb'

trello_cycle_time = AgileTrello::TrelloCycleTime.new(
    public_key: '1c273b1802cd4688c80ae09819ddf533',
    access_token: '59a4fd5c3bf1ef3b749291114297d81d5f802950744bdfee34da7e0183a8db97'
)

# SB
puts "----------  SB ------------" + 10.chr

puts average_cycle_time = trello_cycle_time.get(
    board_id: 'NZTcErZI',
    start_list: 'ToDo',
    end_list: 'Done'
).report

puts "----------  INF ------------" + 10.chr

puts average_cycle_time = trello_cycle_time.get(
    board_id: '4SQmPH8l',
    start_list: 'Sprint Commitment (5th - 18 Mar 2015)',
    end_list: 'Done (current sprint)'
).report
