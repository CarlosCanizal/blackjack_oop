require 'pry'

#Game
class Game
  attr_reader :dealer
  SEPARATOR = "\n------------------------\n"
  def initialize(players)
    @players = players
  end

  def players
    @players
  end

  def start
    @decks = []
    4.times { @decks << Deck.new }
    @dealer = Player.new("Dealer",true)
    @players.each { |player| 2.times { player.hit(get_card) } }
    2.times { @dealer.hit(get_card) }
  end

  def get_card
    rand_deck = rand(@decks.length)
    rand_card = rand(@decks[rand_deck].cards.length)
    @decks[rand_deck].cards[rand_card]
  end

  def play_dealer
    @dealer.hand.initial = false
    while @dealer.hand.total < 16
      @dealer.hit(get_card)
    end
  end

  def results
    results = "*** RESULTS ***\n#{SEPARATOR}#{@dealer}"
    @players.each do  |player| 
      if (player.hand.total == @dealer.hand.total) && player.hand.total <= 21
        results += "#{SEPARATOR}#{player}\nTHIS IS A DRAW, NOBODY WINS! \n"
      elsif player.hand.is_blackjack?
        results += "#{SEPARATOR}#{player}\nBLACKJACK! #{player.name} WINS!"
      elsif player.hand.total > 21 || (@dealer.hand.total > player.hand.total && @dealer.hand.total <=21)
        results += "#{SEPARATOR}#{player}\n#{player.name} LOSES! \n" 
      elsif player.hand.total <= 21
        results += "#{SEPARATOR}#{player}\n#{player.name} WINS! \n" 
      end
    end
    results
  end

  def to_s
    string = ""
    @players.each { |player| string += "#{SEPARATOR}#{player} \n" }
    string += "#{SEPARATOR}#{dealer}"
  end
end

#Player
class Player
  attr_reader :name, :hand
  @@players = 0

  def initialize(name,dealer=false)
    @name = name
    @hand = Hand.new
    @@players+=1
    @dealer = dealer
  end

  def is_dealer?
    @dealer
  end

  def hit(card)
    @hand.hit(card)
    @hand.total
  end

  def to_s
    if is_dealer?
      if @hand.is_initial?
        "#{name} : #{hand.hand[0]}, *"
      else
        "#{name} : #{hand} / Total: #{hand.total}"
      end
    else
      "#{name} : #{hand} / Total: #{hand.total}"
    end
  end
end

class Hand
  attr_reader :hand
  attr_writer :initial
  def initialize
    @hand = []
    @initial = true
  end

  def is_initial?
    @initial
  end

  def hit(card)
    @hand << card
  end

  def total
    hand_total = 0 
    aces = []
    @hand.each do |card|
      if card.symbol == "A"
        aces << card
      else
        hand_total += card.value
      end
    end

    aces.each do |card|
      hand_total += hand_total+card.value > 21 ? 1 : card.value
    end
    hand_total
  end

  def is_blackjack?
    total == 21 && @hand.length == 2
  end

  def is_busted?
    total > 21
  end

  def is_21?
    total == 21
  end

  def to_s
    @hand.join(', ')
  end
end

#Deck
class Deck
  attr_reader :cards
  def initialize
    suits = ["\u2660", "\u2665", "\u2666", "\u2663"]
    values = ["A","2","3","4","5","6","7","8","9","10","J","Q","K"]
    deck = suits.product(values)
    @cards = deck.collect { |card| Card.new(card[0],card[1]) }
  end

  def pop_card
    card_index = rand(@cards.length)
    card = @cards[card_index]
    @cards.delete_at(card_index)
    card
  end
end

#Card
class Card
  attr_reader :suit,:symbol,:value
  VALUES = {"A"=>11,"2"=>2,"3"=>3,"4"=>4,"5"=>5,"6"=>6,"7"=>7,"8"=>8,"9"=>9,"10"=>10,"J"=>10,"Q"=>10,"K"=>10}

  def initialize (suit,symbol)

    @suit = suit
    @symbol = value
    @value = VALUES[symbol]
  end

  def to_s
    "#{suit}#{value}"
  end
end


SEPARATOR = "\n------------------------\n"
def game_start
  puts "WELCOME TO THE CASINO\n"
  puts "\nHi! I'm your Croupier Carlos Canizal, how many players? (1-4)"
  players_total = gets.chomp.to_i
  commands = ["hit", "stay"]


  while players_total < 1 || players_total > 4
    puts "\nPlease type a number between 1 and 4"
    players_total = gets.chomp.to_i
  end

  players = []

  players_total.times do |player|
    puts "\nPlease type the player's #{player+1} name"
    player_name = gets.chomp.capitalize
    players << Player.new(player_name)
  end

  @game = Game.new(players)
  @game.start
  dealer = @game.dealer
  puts "\n\nLET'S PLAY BLACKJACK"
  puts @game

  @game.players.each do |player|
    if player.hand.is_blackjack?
      command = 'stay' 
    else
      command = 'hit'
      puts SEPARATOR
      puts "NOW PLAYING: #{player.name}.\n\n"
      puts player
      puts dealer
      while commands.include? command
        puts "\nDo you want hit or stay? "
        command = gets.chomp.downcase

        until commands.include? command
          puts "\n\nVALID COMMANS ARE : 'hit' or 'stay'"
          command = gets.chomp.downcase
        end

        if command == 'hit'
          puts SEPARATOR
          puts "DEALER GIVES YOU NEW CARD."
          player.hit(@game.get_card)
          puts player 
          puts dealer
          if player.hand.is_busted?
            puts "SORRY, YOU LOSE!." 
            command = 'stay'
          elsif player.hand.is_21?
            command = 'stay'
          end
        end
      end
    end
  end
  @game.play_dealer
  system("clear")
  puts @game.results
end

commands = ["yes","no","y","n"]
command = 'yes'
while commands.include? command
  system("clear")
  game_start
  puts "\n\nDo you want to play again? yes/no"
  command = gets.chomp.downcase
  until commands.include? command
    puts "\n\nVALID COMMANDS ARE : 'yes' or 'not' "
    command = gets.chomp.downcase
  end
end





