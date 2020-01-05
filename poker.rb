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
  attr_accessor :cards, :pocket, :community

  def initialize(game, cards = nil, community_cards = nil)
    @pocket = cards || game.deck.cards.sample(2)
    game.deck.remove_cards(@pocket)

    @community = community_cards || game.deck.cards.sample(5)
    game.deck.remove_cards(@community)

    @cards = @pocket + @community
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

  def suit_hash
    @suit_hash ||=
      begin
        @cards.each_with_object({}) do |card, memo|
          if memo[card.suit].present?
            memo[card.suit] = memo[card.suit] + 1
          else
            memo[card.suit] = 1
          end
        end
      end
  end

  def evaluate
    puts "Community cards: ", "#{@community.map { |card| card.name }.join(', ')}"
    puts "Your cards: ", "#{@pocket.map { |card| card.name }.join(', ')}"

    # TODO: refactor these evaluations into a ranked result so they can be
    #   compared in the future
    if check_for_royal_flush
      puts 'You have a royal flush'
      return
    end

    if check_for_straight_flush
      puts 'You have a straight flush'
      return
    end

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

    puts 'You have a high card'
  end

  def check_for_royal_flush
    flush = check_for_flush

    flush.present? &&
      check_for_straight(flush) &&
      flush.sort.reverse.first.rank == 14 &&
      flush.sort.reverse.last.rank == 10
  end

  def check_for_straight_flush
    flush = check_for_flush
    flush.present? && check_for_straight(flush)
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
    flushed_suit = suit_hash.detect { |suit, count| count == 5 }&.first
    return false unless flushed_suit.present?
    cards.select { |card| card.suit == flushed_suit }
  end

  def check_for_straight(cards_to_check = cards)
    sorted_cards = cards_to_check.sort.reverse
    ace_low_straight = false

    if sorted_cards.first.rank == 14
      low_ace = Card.new(1, sorted_cards.last.suit, 'A')
      ace_low_sorted = sorted_cards[1..-1] + [low_ace]

      ace_low_straight = check_straight_ranks(ace_low_sorted)
    end

    ace_low_straight || check_straight_ranks(sorted_cards)
  end

  def check_straight_ranks(cards)
    (0..2).any? do |index|
      cards[index + 1].rank == cards[index].rank - 1 &&
      cards[index + 2].rank == cards[index + 1].rank - 1 &&
      cards[index + 3].rank == cards[index + 2].rank - 1 &&
      cards[index + 4].rank == cards[index + 3].rank - 1
    end
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

  def remove_cards(cards_to_remove)
    @cards = @cards - cards_to_remove
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

  def parse_pocket_cards(cards_string)
    cards = cards_string.split(' ')

    cards.map do |card|
      suit = case card[-1]
             when 'S'
               :spades
             when 'C'
               :clubs
             when 'H'
               :hearts
             when 'D'
               :diamonds
             end
      rank = case card[0]
             when '2'
               2
             when '3'
               3
             when '4'
               4
             when '5'
               5
             when '6'
               6
             when '7'
               7
             when '8'
               8
             when '9'
               9
             when '1'
               10
             when 'J'
               11
             when 'Q'
               12
             when 'K'
               13
             when 'A'
               14
             end
      @deck.cards.detect do |kard|
        kard.rank == rank && kard.suit == suit
      end
    end
  end
end


unless ENV['TEST']
  game = Game.new
  print "Enter your cards\n"
  pocket_cards_string = gets

  pocket_card_objects = game.parse_pocket_cards(pocket_cards_string)

  hand = Hand.new(game, pocket_card_objects)
  game.deal(hand).evaluate
end
