# frozen_string_literal: true

# class Human for methods that are only specific to the user
class Human
  def self.ask_code
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
end

# class Computer for methods that are specific to the computer
class Computer
  def self.random_digits
    digits = (1..6).to_a
    sample_digits = []
    4.times { sample_digits.push(digits.sample) }
    sample_digits
  end
end

# the one that plays the role of CodeMaker
class CodeMaker
  attr_reader :code

  def initialize
    @code = Computer.random_digits
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

  def update_guess
    @guess = Human.ask_code.split('').map(&:to_i)
    display
  end

  def display
    puts "Your guess: #{guess.join('')}"
  end
end

# controlling game flows from here
class Game
  attr_reader :codemaker, :codebreaker

  def initialize
    @codemaker = CodeMaker.new
    @codebreaker = CodeBreaker.new
  end

  def play
    intro
    i = 1
    until i > 12 || all_correct?
      puts "Round #{i}"
      codebreaker.update_guess
      feedback
      puts
      i += 1
    end
  end

  def intro
    puts 'Welcome to Mastermind. In this game, you will have to crack a 4 digit code (numbers only from 1 to 6) set by the computer.'
    puts 'You have 12 chances to guess the code. Get crackin.'
    puts
  end

  def all_correct?
    codebreaker.guess == codemaker.code
  end

  def feedback
    pos_count = count_correct_pos
    digit_count = count_correct_digit

    digit_count -= pos_count if digit_count.positive? && pos_count.positive?

    if pos_count.positive?
      puts "#{pos_count} #{digit_quantity(pos_count)} at the right #{position_quantity(pos_count)}."
    end

    if digit_count.positive?
      puts "#{digit_count} #{digit_quantity(digit_count)} the right #{integer_quantity(digit_count)} but at the wrong #{position_quantity(digit_count)}."
    end

    puts 'None of the digits in the guesses are in the code.' if pos_count.zero? && digit_count.zero?
  end

  def count_correct_pos
    correct_pos_count = 0

    codemaker.code.each_with_index do |digit, index|
      correct_pos_count += 1 if digit == codebreaker.guess[index]
    end

    correct_pos_count
  end

  def count_correct_digit
    correct_digit_count = 0
    digits_in_code_and_guess = codebreaker.guess.select { |digit| codemaker.code.include?(digit) }.uniq

    digits_in_code_and_guess.each do |digit|
      digit_count_in_code = codemaker.code.count(digit)
      digit_count_in_guess = codebreaker.guess.count(digit)

      correct_digit_count += if digit_count_in_guess < digit_count_in_code
                               digit_count_in_guess
                             else
                               digit_count_in_code
                             end
    end
    correct_digit_count
  end

  def digit_quantity(digit)
    if digit == 1
      'digit is'
    else
      'digits are'
    end
  end

  def integer_quantity(digit)
    if digit == 1
      'integer'
    else
      'integers'
    end
  end

  def position_quantity(digit)
    if digit == 1
      'position'
    else
      'positions'
    end
  end
end

Game.new.play
