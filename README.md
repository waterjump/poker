Poker
=====
This app deals five cards psuedorandomly and evaluates if there's a valid poker hand.  Right now it's five card stud, but the plan is to make it so it can predict the winning chances of a Texas Holdem hand.  For example, pocket aces are more likely to win than a 2 and a 7 of different suits.  This app will provide statistics for that.

## Install
(You need ruby and bundler)
1. Clone the repo: `git clone git@github.com:waterjump/poker.git`
2. Install depedencies: `bundle install`

## Running the program
Run the main file: `ruby poker.rb` _WARNING: You may shit yourself from having so much fun._

## Testing
1. Follow the install instruction above.
2. Run rspec: `bundle exec rspec`
