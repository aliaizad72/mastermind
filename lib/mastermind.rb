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

# class Role which is the abstraction above CodeMaker & CodeBreaker
class Role
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

  def display
    puts "Your #{array_name}: #{digit_array.join('')}"
  end

  def intro
    puts "As a #{self.class}, you have to crack a 4 digit code. \n" \
         "The code #{auxilary_verb} made of integers from 1 to 6, with duplicates allowed. \n" \
         "#{codebreaker.capitalize} have 12 chances to guess the code. Good luck! \n" \
         "\n"
  end
end

# the one that plays the role of CodeMaker
class CodeMaker < Role
  def array_name
    'code'
  end

  def auxilary_verb
    'should be'
  end

  def codebreaker
    'the computer'
  end
end

# the one that tries to break the code; in this first case the Player
class CodeBreaker < Role
  def array_name
    'guess'
  end

  def auxilary_verb
    'are'
  end

  def codebreaker
    'you'
  end

  def set_digit_array
    super
    display
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
      codebreaker.set_digit_array
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
    position_count = count_position
    integer_count = count_integer

    integer_count -= position_count if integer_count.positive? && position_count.positive?

    if position_count.positive?
      puts "#{position_count} #{digit_quantity(position_count)} at the right #{position_quantity(position_count)}."
    end

    if integer_count.positive?
      puts "#{integer_count} #{digit_quantity(integer_count)} the right #{integer_quantity(integer_count)} but at the wrong #{position_quantity(integer_count)}."
    end

    puts 'None of the digits in the guesses are in the code.' if position_count.zero? && integer_count.zero?
  end

  def count_position
    correct_position_count = 0

    codemaker.digit_array.each_with_index do |digit, index|
      correct_position_count += 1 if digit == codebreaker.digit_array[index]
    end

    correct_position_count
  end

  def count_integer
    correct_integer_count = 0
    digits_in_code_and_guess = codebreaker.digit_array.select { |digit| codemaker.digit_array.include?(digit) }.uniq

    digits_in_code_and_guess.each do |digit|
      integer_count_in_code = codemaker.digit_array.count(digit)
      integer_count_in_guess = codebreaker.digit_array.count(digit)

      correct_integer_count += if integer_count_in_guess < integer_count_in_code
                                 integer_count_in_guess
                               else
                                 integer_count_in_code
                               end
    end
    correct_integer_count
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
