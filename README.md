Poker
=====
This program takes user input for the player's pocket cards, and deals five community cards as in Texas Holdem, then evaluates what hand the player has.

The input format is as follows:
`<card rank><card suit> <card rank><card suit>`
where card rank is number 2 - 10, J Q K or A and card suit is 'H' for hearts, 'S' for spades, 'D' for diamonds or 'C' for clubs.

For example, if you have pocket cards ace of spades and 3 of diamonds, you would input `AS 3D`.

## Install
(You need ruby and bundler)
1. Clone the repo: `git clone git@github.com:waterjump/poker.git`
2. Install depedencies: `bundle install`

## Running the program
Run the main file: `ruby poker.rb` _WARNING: You may shit yourself from having so much fun._

## Testing
1. Follow the install instruction above.
2. Run rspec: `TEST=true bundle exec rspec`
