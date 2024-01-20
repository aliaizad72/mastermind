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
  def display_code
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
    @guess = ask_code.split('').map(&:to_i)
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
    # intro
    puts 'Welcome to Mastermind. In this game, you will have to crack a 4 digit code (numbers only from 1 to 6) set by the computer.'
    puts "You have 12 chances to guess the code. Get crackin."
    puts
    i = 1
    until i > 12 || all_correct?
      puts "Round #{i}"
      current_guesser.update_guess
      puts feedback
      puts
      i += 1
    end
  end

  def all_correct?
    current_guesser.guess == current_maker.code
  end

  def feedback
    hijau_pegs = correct_position
    putih_pegs = correct_digit_only

    putih_pegs -= hijau_pegs if putih_pegs.positive? && hijau_pegs.positive?
    
    if hijau_pegs.positive? && putih_pegs.positive?
      "#{hijau_pegs} digit(s) are at the right position, while #{putih_pegs} digit(s) are the right digit(s), but at the wrong position."
    elsif hijau_pegs.positive? && putih_pegs.zero?
      "#{hijau_pegs} digit(s) are at the right position."
    elsif hijau_pegs.zero? && putih_pegs.positive?
      "#{putih_pegs} digit(s) are the right digit(s), but at the wrong position."
    else
      'None of the digits in the guesses are in the code.'
    end
  end

  def correct_position
    correct_pos_count = 0

    current_maker.code.each_with_index do |digit, index|
      correct_pos_count += 1 if digit == current_guesser.guess[index]
    end

    correct_pos_count
  end

  def correct_digit_only
    correct_digit_count = 0
    digits_in_code_and_guess = current_guesser.guess.select { |digit| current_maker.code.include?(digit) }.uniq

    digits_in_code_and_guess.each do |digit|
      digit_count_in_code = current_maker.code.count(digit)
      digit_count_in_guess = current_guesser.guess.count(digit)

      correct_digit_count += if digit_count_in_guess < digit_count_in_code
                               digit_count_in_guess
                             else
                               digit_count_in_code
                             end
    end
    correct_digit_count
  end
end

Game.new.play
