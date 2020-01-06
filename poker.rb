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
    puts "\nCommunity cards: ", "#{@community.map { |card| card.name }.join(', ')}"
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
    (0..cards.count - 5).any? do |index|
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

    raise 'Too few cards' if cards.size < 2
    raise 'Too many cards' if cards.size > 2

    all_cards_valid = cards.all? do |card|
      card.length == 2 || (card.length == 3 && card[0..1] == '10')
    end
    raise 'Invalid input' unless all_cards_valid

    cards.map do |card|
      suit = case card[-1]
             when 'S', 's'
               :spades
             when 'C', 'c'
               :clubs
             when 'H', 'h'
               :hearts
             when 'D', 'd'
               :diamonds
             else
               raise 'Invalid suit'
             end

      rank = case card[0]
             when '2', '3', '4', '5', '6', '7', '8', '9'
               card[0].to_i
             when '1'
               10
             when 'J', 'j'
               11
             when 'Q', 'q'
               12
             when 'K', 'k'
               13
             when 'A', 'a'
               14
             else
               raise 'Invalid rank'
             end

      @deck.cards.detect do |kard|
        kard.rank == rank && kard.suit == suit
      end
    end
  end
end

unless ENV['TEST']
  game = Game.new
  def get_play_cards(game)
    print "Enter your cards\n"
    pocket_cards_string = gets

    game.parse_pocket_cards(pocket_cards_string)
  rescue => e
    print "Your cards must be in a format like this: \n"
    print "<card rank><card suit> <card rank><card suit>\n\n"
    print "For example: 3H AC\n\n"
    print "Please try again.\n\n"
    get_play_cards(game)
  end

  pocket_card_objects = get_play_cards(game)

  hand = Hand.new(game, pocket_card_objects)
  game.deal(hand).evaluate
end
