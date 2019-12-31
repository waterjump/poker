require 'byebug'
require 'active_support'
require 'active_support/core_ext/object'

class Card
  attr_accessor :character, :suit, :rank

  def initialize(rank, suit, character)
    @rank = rank
    @suit = suit
    @character = character
  end

  def name
    "#{@character} of #{@suit}"
  end

  def <=>(other_item)
    return  0 if self.rank == other_item.rank
    return -1 if self.rank < other_item.rank
    return  1 if self.rank > other_item.rank
  end
end

class Hand
  attr_accessor :cards

  def initialize(game, cards = nil)
    @cards = cards || game.deck.cards.sample(5)
  end

  def hash
    @hash ||=
      begin
        @cards.each_with_object({}) do |card, memo|
          if memo[card.character].present?
            memo[card.character] = memo[card.character] + 1
          else
            memo[card.character] = 1
          end
        end
      end
  end

  def evaluate
    puts "Your cards: ", "#{@cards.map { |card| card.name }.join(', ')}"

    if check_for_four_of_a_kind
      puts "You have four #{check_for_four_of_a_kind}s!"
      return
    end

    if check_for_full_house
      puts "You have a full house!"
      return
    end

    if check_for_flush
      puts "You have a flush"
      return
    end

    if check_for_straight
      puts 'You have a straight'
      return
    end

    if check_for_three_of_a_kind
      puts "You have three #{check_for_three_of_a_kind}s!"
      return
    end

    if check_for_two_pair
      puts "You have two pair!"
      return
    end

    if check_for_pair
      puts "You have a pair of #{check_for_pair}s!"
      return
    end
  end

  def check_for_three_of_a_kind
    hash.each do |character, count|
      return character if count == 3
    end
    false
  end

  def check_for_full_house
    [check_for_pair, check_for_three_of_a_kind].all?(&:present?)
  end

  def check_for_four_of_a_kind
    hash.each do |character, count|
      return character if count == 4
    end
    false
  end

  def check_for_two_pair
    hash.values.select { |val| val == 2 }.size == 2
  end

  def check_for_pair
    hash.each do |character, count|
      return character if count == 2
    end
    false
  end

  def check_for_flush
    suits = cards.map(&:suit).uniq
    return true if suits.size == 1
    false
  end

  def check_for_straight
    sorted_cards = cards.sort.reverse
    ace_low_straight = false

    if sorted_cards.first.rank == 14
      low_ace = Card.new(1, sorted_cards.last.suit, 'A')
      ace_low_sorted = sorted_cards[1..-1] + [low_ace]

      ace_low_straight = check_straight_ranks(ace_low_sorted)
    end

    ace_low_straight || check_straight_ranks(sorted_cards)
  end

  def check_straight_ranks(cards)
    cards[1].rank == cards[0].rank - 1 &&
    cards[2].rank == cards[1].rank - 1 &&
    cards[3].rank == cards[2].rank - 1 &&
    cards[4].rank == cards[3].rank - 1
  end
end

class Deck
  attr_accessor :cards

  def initialize
    @cards = []
    ranks = [
      [2, '2'],
      [3, '3'],
      [4, '4'],
      [5, '5'],
      [6, '6'],
      [7, '7'],
      [8, '8'],
      [9, '9'],
      [10, '10'],
      [11, 'J'],
      [12, 'Q'],
      [13, 'K'],
      [14, 'A']
    ]

    %i(hearts diamonds spades clubs).each do |suit|
      ranks.each do |rank, character|
        @cards << Card.new(rank, suit, character)
      end
    end
  end
end

class Game
  attr_accessor :deck, :hand

  def initialize
    @deck = Deck.new
  end

  def deal(hand = nil)
    @hand ||= hand || Hand.new(self)
  end
end

Game.new.deal.evaluate
