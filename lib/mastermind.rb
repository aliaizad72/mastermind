# controlling game flows from here
class Game
  attr_accessor :human, :codemaker, :codebreaker, :integer_count, :position_count

  def initialize
    create_players
    intro
    @codemaker.set_array
  end

  def create_players
    @players = Input.ask_role
    @codemaker = @players.select { |player| player.instance_of? CodeMaker } [0]
    @codebreaker = @players.select { |player| player.instance_of? CodeBreaker } [0]
    @human = @players.select(&:human) [0]
  end

  def play
    i = 1
    until i > 12 || all_correct?
      puts "Round #{i}"
      codebreaker.set_array
      count
      feedback
      puts
      i += 1
    end
  end

  def intro
    puts 'Welcome to Mastermind.'
    human.intro
  end

  def all_correct?
    codebreaker.array == codemaker.array
  end

  def count
    @position_count = codemaker.array.count_position(codebreaker.array)
    @integer_count = codemaker.array.sum_lowest_common_integer(codebreaker.array)
    @integer_count -= @position_count if integer_count.positive? && position_count.positive?
  end

  def feedback
    right_position if position_count.positive?
    right_integer if integer_count.positive?
    none_correct if position_count.zero? && integer_count.zero?
  end

  def right_position
    puts "#{position_count} #{digit_quantity(position_count)} at the right #{position_quantity(position_count)}."
  end

  def right_integer
    puts "#{integer_count} #{digit_quantity(integer_count)} the right #{integer_quantity(integer_count)} but at the wrong #{position_quantity(integer_count)}."
  end

  def none_correct
    puts 'None of the integers in the guesses are in the code.'
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

# class Input for methods that take input from the user
class Input
  def self.ask_role # rubocop:disable Metrics/MethodLength
    input = '0'
    i = 0

    until %w[1 2].include?(input)
      print 'Enter 1 to be the CodeMaker, or enter 2 to be the CodeBreaker: ' if i.zero?
      print 'Please enter 1 or 2 only! Try again: ' if i.positive?
      input = gets.chomp
      i += 1
    end
    puts
    return [CodeMaker.new(human: true), CodeBreaker.new(human: false)] if input == '1'

    [CodeMaker.new(human: false), CodeBreaker.new(human: true)] if input == '2'
  end

  def self.ask_array # rubocop:disable Metrics/MethodLength
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

# class Role which is the abstraction above CodeMaker & CodeBreaker
class Role
  attr_accessor :human, :array

  def initialize(human: false)
    @human = human
    @array = [0, 0, 0, 0]
  end

  def set_array
    @array = if human
               array_from_input
             else
               Computer.random_digits
             end
  end

  def array_from_input
    Input.ask_array.split('').map(&:to_i)
  end

  def display
    puts "Your #{array_name}: #{array.join('')}"
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

  def set_array
    super
    display
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

# extending Array with method specific to this game
class Array
  def count_position(array)
    correct_position_count = 0
    each_with_index { |digit, index| correct_position_count += 1 if digit == array[index] }
    correct_position_count
  end

  def sum_lowest_common_integer(array)
    correct_integer_count = 0
    common_integer = intersection(array)
    common_integer.each { |digit| correct_integer_count += [count(digit), array.count(digit)].min }
    correct_integer_count
  end
end

# extending class Integer for output in the feedback
class Integer
  def to_be
    if self == 1
      'is'
    else
      'are'
    end
  end
end
Game.new.play
