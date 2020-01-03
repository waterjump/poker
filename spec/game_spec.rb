require_relative '../poker'

RSpec.describe Game do
  let(:game) { Game.new }

  it 'has a 52 card deck' do
    expect(game.deck.cards.size).to eq(52)
  end

  it 'deals five cards' do
    expect(game.deal.cards.size).to eq(5)
  end
end

RSpec.describe Deck do
  let(:game) { Game.new }

  describe 'dealing cards' do
    it 'removes cards from deck' do
      expect { game.deal }.to change { game.deck.cards.size }.by(-5)
    end
  end

  describe '#remove_cards' do
    it 'removes specific cards from the deck' do
      card_to_remove = game.deck.cards.sample

      expect(game.deck.cards).to include(card_to_remove)

      game.deck.remove_cards([card_to_remove])

      expect(game.deck.cards).not_to include(card_to_remove)
    end
  end
end

RSpec.describe Hand do
  let(:game) { Game.new }

  let(:high_card_hand) do
    Hand.new(game,
      [
        Card.new(2, :spades, '2'),
        Card.new(8, :hearts, '8'),
        Card.new(4, :hearts, '4'),
        Card.new(11, :clubs, 'J'),
        Card.new(7, :diamonds, '7')
      ]
    )
  end

  describe 'a royal flush' do
    it 'notifies a royal flush result' do
      royal_flush =
        Hand.new(game,
          [
            Card.new(11, :spades, 'J'),
            Card.new(14, :spades, 'A'),
            Card.new(10, :spades, '10'),
            Card.new(12, :spades, 'Q'),
            Card.new(13, :spades, 'K')
          ]
        )

      expect { royal_flush.evaluate }.to(
        output(/You have a royal flush.*/).to_stdout
      )
    end

    context 'when not a royal flush' do
      it 'does not notify of a royal flush' do
        five_high_flush =
          Hand.new(game,
            [
              Card.new(4, :spades, '4'),
              Card.new(5, :spades, '5'),
              Card.new(14, :spades, 'A'),
              Card.new(2, :spades, '2'),
              Card.new(3, :spades, '3')
            ]
          )

        expect { five_high_flush.evaluate }.not_to(
          output(/You have a royal flush.*/).to_stdout
        )
      end
    end
  end

  describe 'a straight flush' do
    it 'notifies a straight flush result' do
      straight =
        Hand.new(game,
          [
            Card.new(11, :spades, 'J'),
            Card.new(8, :spades, '8'),
            Card.new(10, :spades, '10'),
            Card.new(7, :spades, '7'),
            Card.new(9, :spades, '9')
          ]
        )

      expect { straight.evaluate }.to(
        output(/You have a straight flush.*/).to_stdout
      )
    end
  end

  describe 'four of a kind' do
    context 'when hand has four of a kind' do
      it 'notifies a four of a kind result' do
        four_of_a_kind =
          Hand.new(game,
            [
              Card.new(2, :spades, '2'),
              Card.new(2, :hearts, '2'),
              Card.new(2, :diamonds, '2'),
              Card.new(2, :clubs, '2'),
              Card.new(7, :diamonds, '7')
            ]
          )

        expect { four_of_a_kind.evaluate }.to(
          output(/You have four 2s!.*/).to_stdout
        )
      end
    end

    context 'when hand has no four of a kind' do
      it 'does not notify four of a kind has been evaluated' do
        expect { high_card_hand.evaluate }.not_to(
          output(/You have four of a kind.*/).to_stdout
        )
      end
    end
  end

  describe 'full house' do
    context 'when hand has full house' do
      it 'notifies a full house result' do
        full_house =
          Hand.new(game,
            [
              Card.new(2, :spades, '2'),
              Card.new(2, :hearts, '2'),
              Card.new(3, :diamonds, '3'),
              Card.new(3, :clubs, '3'),
              Card.new(3, :hearts, '3')
            ]
          )

        expect { full_house.evaluate }.to(
          output(/You have a full house!.*/).to_stdout
        )
      end
    end

    context 'when hand has no four of a kind' do
      it 'does not notify four of a kind has been evaluated' do
        expect { high_card_hand.evaluate }.not_to(
          output(/You have a full house!.*/).to_stdout
        )
      end
    end
  end

  describe 'a flush' do
    context 'when hand has a flush' do
      it 'notifies a flush result' do
        flush =
          Hand.new(game,
            [
              Card.new(2, :spades, '2'),
              Card.new(13, :spades, 'K'),
              Card.new(1, :spades, 'A'),
              Card.new(12, :spades, 'Q'),
              Card.new(7, :spades, '7')
            ]
          )

        expect { flush.evaluate }.to(
          output(/You have a flush.*/).to_stdout
        )
      end
    end

    context 'when hand has no flush' do
      it 'does not notify flush result' do
        expect { high_card_hand.evaluate }.not_to(
          output(/You have a flush.*/).to_stdout
        )
      end
    end
  end

  describe 'a straight' do
    context 'when hand has a straight' do
      it 'notifies a straight result' do
        straight =
          Hand.new(game,
            [
              Card.new(11, :spades, 'J'),
              Card.new(8, :hearts, '8'),
              Card.new(9, :clubs, '9'),
              Card.new(10, :diamonds, '10'),
              Card.new(7, :spades, '7')
            ]
          )

        expect { straight.evaluate }.to(
          output(/You have a straight.*/).to_stdout
        )
      end
    end

    context 'when hand has an ace high straight' do
      it 'notifies a straight result' do
        straight =
          Hand.new(game,
            [
              Card.new(11, :spades, 'J'),
              Card.new(14, :hearts, 'A'),
              Card.new(10, :clubs, '10'),
              Card.new(12, :diamonds, 'Q'),
              Card.new(13, :spades, 'K')
            ]
          )

        expect { straight.evaluate }.to(
          output(/You have a straight.*/).to_stdout
        )
      end
    end

    context 'when hand has an ace low straight' do
      it 'notifies a straight result' do
        straight =
          Hand.new(game,
            [
              Card.new(2, :spades, '2'),
              Card.new(14, :hearts, 'A'),
              Card.new(3, :clubs, '3'),
              Card.new(5, :diamonds, '5'),
              Card.new(4, :spades, '4')
            ]
          )

        expect { straight.evaluate }.to(
          output(/You have a straight.*/).to_stdout
        )
      end
    end

    context 'when hand has no straight' do
      it 'does not notify a straight result' do
        expect { high_card_hand.evaluate }.not_to(
          output(/You have a straight.*/).to_stdout
        )
      end
    end
  end

  describe 'three of a kind' do
    context 'when hand has three of a kind' do
      it 'notifies a three of a kind result' do
        three_of_a_kind =
          Hand.new(game,
            [
              Card.new(2, :spades, '2'),
              Card.new(2, :hearts, '2'),
              Card.new(4, :hearts, '4'),
              Card.new(2, :clubs, '2'),
              Card.new(7, :diamonds, '7')
            ]
          )

        expect { three_of_a_kind.evaluate }.to(
          output(/You have three 2s!.*/).to_stdout
        )
      end
    end

    context 'when hand has no three of a kind' do
      it 'does not notify three of a kind has been evaluated' do
        expect { high_card_hand.evaluate }.not_to(
          output(/You have three of a kind.*/).to_stdout
        )
      end
    end
  end

  describe 'two pair' do
    context 'when hand has two pair' do
      it 'notifies two pair has been evaluated' do
        two_pair =
          Hand.new(game,
            [
              Card.new(2, :spades, '2'),
              Card.new(2, :hearts, '2'),
              Card.new(4, :hearts, '4'),
              Card.new(4, :clubs, '4'),
              Card.new(7, :diamonds, '7')
            ]
          )

        expect { two_pair.evaluate }.to(
          output(/You have two pair!.*/).to_stdout
        )
      end
    end

    context 'when hand does not have two pair' do
      it 'does not notiify two pair has been evaluated' do
        expect { high_card_hand.evaluate }.not_to(
          output(/You have a pair of 2s!.*/).to_stdout
        )
      end
    end
  end

  describe 'a pair' do
    context 'when hand has a pair' do
      it 'notifies a pair has been evaluated' do
        pair =
          Hand.new(game,
            [
              Card.new(2, :spades, '2'),
              Card.new(2, :hearts, '2'),
              Card.new(4, :hearts, '4'),
              Card.new(11, :clubs, 'J'),
              Card.new(7, :diamonds, '7')
            ]
          )

        expect { pair.evaluate }.to(
          output(/You have a pair of 2s!.*/).to_stdout
        )
      end
    end

    context 'when hand has no pair' do
      it 'does not notiify pair has been evaluated' do
        expect { high_card_hand.evaluate }.not_to(
          output(/You have a pair of 2s!.*/).to_stdout
        )
      end
    end
  end

  describe 'high card' do
    it 'notifies a high card result' do
      expect { high_card_hand.evaluate }.to(
        output(/You have a high card.*/).to_stdout
      )
    end
  end
end
