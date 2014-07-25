trello-cycletime
================

Calculates cycle time from cards on a trello board

[![Build Status](https://drone.io/github.com/code-computerlove/trello-cycletime/status.png)](https://drone.io/github.com/code-computerlove/trello-cycletime/latest)

##Introduction

This gem contains a class that can be used for calculating cycle time from cards on a trello board 

##Installation

The package is installed on rubygems and can be installed using the following command

    gem install 'TrelloCycleTime'

or adding the following to your Gemfile
    
    gem 'TrelloCycleTime'

##Example

    require 'TrelloCycleTime'

    trello_cycle_time = AgileTrello::TrelloCycleTime.new(
	    public_key: 'aPublickey',
	    access_token: 'anAccessToken'
    )

    MY_BOARD_ID = '5aJf2ZMz'

    average_cycle_time = trello_cycle_time.get(
	    board_id: MY_BOARD_ID,
	    start_list: 'In Progress',
	    end_list: 'Ready for Release'
    )

    puts average_cycle_time.mean
    
##Trello Gotchas
You can get the access_token key by going to this url in your browser:
https://trello.com/1/authorize?key=YOUR_PUBLIC_KEY&name=YOUR_APP_NAME&response_type=token&scope=read,write,account&expiration=never

Your board id is included in the board uri e.g. in the uri https://trello.com/b/Fwrt4xH5/myBoard the id is Fwrt4xH5
