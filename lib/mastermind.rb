# frozen_string_literal: true

# class Human for methods that are only specific to the user
class Human
  def self.ask_role
    input = '0'
    i = 0

    until %w[1 2].include?(input)
      print 'Enter 1 to be the CodeMaker, or enter 2 to be the CodeBreaker: ' if i.zero?
      print 'Please enter 1 or 2 only! Try again: ' if i.positive?
      input = gets.chomp
      i += 1
    end
    puts
    return 'codemaker' if input == '1'

    'codebreaker' if input == '2'
  end

  def self.ask_digit_array
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

  def self.update_array
    Human.ask_digit_array.split('').map(&:to_i)
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
  attr_accessor :human, :digit_array

  def initialize(human: false)
    @human = human
    @digit_array = [0, 0, 0, 0]
  end

  def set_digit_array
    @digit_array = if human
              Human.update_array
            else
              Computer.random_digits
            end
  end

  def intro
    puts 'As a CodeMaker, you have to enter a 4 digit code.'
    puts 'The code can only be made of integers from 1 to 6. Duplicate integers allowed.'
    puts 'The computer will try to guess your code in 12 tries. Good luck!'
    puts
  end

  # temp method to ensure things are working well
  def display_digit_array
    puts "Code: #{digit_array.join('')} " # remove 'code' when game done!
  end
end

# the one that tries to break the code; in this first case the Player
class CodeBreaker
  attr_accessor :human, :digit_array

  def initialize(human: true)
    @human = human
    @digit_array = [0, 0, 0, 0]
  end

  def update_digit_array
    @digit_array = if human
                     Human.update_array
                   else
                     Computer.random_digits
                   end
    display
  end

  def intro
    puts 'As a CodeBreaker, you will have to crack a 4 digit code.'
    puts 'The code are made of integers from 1 to 6, with duplicates allowed.'
    puts 'You have 12 chances to guess the code. Get crackin.'
    puts
  end

  def display
    puts "Your guess: #{digit_array.join('')}"
  end
end

# controlling game flows from here
class Game
  attr_reader :codemaker, :codebreaker

  def initialize
    create_players
    intro
    @codemaker.set_digit_array
  end

  def create_players
    human_role = Human.ask_role

    @codemaker = if human_role == 'codemaker'
                   CodeMaker.new(human: true)
                 else
                   CodeMaker.new(human: false)
                 end

    @codebreaker = if human_role == 'codebreaker'
                     CodeBreaker.new(human: true)
                   else
                     CodeBreaker.new(human: false)
                   end
  end

  def play
    i = 1
    until i > 12 || all_correct?
      puts "Round #{i}"
      codebreaker.update_digit_array
      feedback
      puts
      i += 1
    end
  end

  def intro
    puts 'Welcome to Mastermind.'
    if codemaker.human
      codemaker.intro
    elsif codebreaker.human
      codebreaker.intro
    end
  end

  def all_correct?
    codebreaker.digit_array == codemaker.digit_array
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

    codemaker.digit_array.each_with_index do |digit, index|
      correct_pos_count += 1 if digit == codebreaker.digit_array[index]
    end

    correct_pos_count
  end

  def count_correct_digit
    correct_digit_count = 0
    digits_in_code_and_guess = codebreaker.digit_array.select { |digit| codemaker.digit_array.include?(digit) }.uniq

    digits_in_code_and_guess.each do |digit|
      digit_count_in_code = codemaker.digit_array.count(digit)
      digit_count_in_guess = codebreaker.digit_array.count(digit)

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
