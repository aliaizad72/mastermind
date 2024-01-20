# frozen_string_literal: true

# the one that plays the role of CodeMaker
class CodeMaker
  attr_reader :code

  def initialize
    @code = random_digits
  end

  def random_digits
    digits = (1..6).to_a
    sample_digits = []
    4.times { sample_digits.push(digits.sample) }
    sample_digits
  end

  # temp method to ensure things are working well
  def display
    puts "Code: #{code.join('')} " # remove 'code' when game done!
  end
end

# the one that tries to break the code; in this first case the Player
class CodeBreaker
  attr_accessor :guess

  def initialize
    @guess = Array.new(4, 0)
  end

  def ask_code
    input = 'empty'
    n = 0
    until input.length == 4 && input.to_i.positive?
      if n.zero?
        print 'Enter the 4 digit code: '
      else
        print 'Please enter 4 digits and integers only. Try again: '
      end
      input = gets.chomp
      n += 1
    end
    input
  end

  def update_guess
    @guess = ask_code.split('')
    display
  end

  def display
    puts "Your guess: #{guess.join('')}"
  end
end

# controlling game flows from here
class Game
  attr_reader :current_maker, :current_guesser

  def initialize
    @current_maker = CodeMaker.new
    @current_guesser = CodeBreaker.new
  end

  def play
    i = 0
    until i > 11 && all_correct?
      current_guesser.update_guess
      p all_correct?
      i += 1
    end
  end

  def all_correct?
    current_guesser.guess == current_maker
  end
end

Game.new.play
