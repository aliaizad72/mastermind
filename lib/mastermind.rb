# frozen_string_literal: true
require 'colorize'

# controlling game flows from here
class Game
  attr_accessor :human, :codemaker, :codebreaker, :integer_count, :position_count

  def initialize
    intro
    create_players
    human.intro
    codemaker.set_array
  end

  def create_players
    @players = role_factory
    @codemaker = @players.select { |player| player.instance_of? CodeMaker } [0]
    @codebreaker = @players.select { |player| player.instance_of? CodeBreaker } [0]
    @human = @players.select(&:human) [0]
  end

  def role_factory # rubocop:disable Metrics/MethodLength
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

  def play
    i = 1
    until i > 12 || all_correct?
      puts "\nRound #{i}".colorize(color: :cyan, mode: :bold)
      codebreaker.set_array
      count
      feedback
      codebreaker.calculate
      i += 1
    end
    announce_winner if all_correct?
    announce_loser if i > 12
  end

  def intro
    puts 'Welcome to Mastermind!'.colorize(color: :cyan, mode: :bold)
    puts
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
    codebreaker.guess_feedback = [position_count, integer_count]
    print_position_count
    print_integer_count
  end

  def print_position_count
    puts "Right integer, right position: #{position_count}".colorize(color: :green)
  end

  def print_integer_count
    puts "Right integer, wrong position: #{integer_count}".colorize(color: :blue)
  end

  def announce_winner
    if codebreaker.human
      puts 'Congratulations! You have cracked the code!'.colorize(color: :cyan, mode: :bold)
    else
      puts 'The computer has cracked your code! You lose!'.colorize(color: :red, mode: :bold)
    end
  end

  def announce_loser
    if codebreaker.human
      puts 'You could not crack the code! You lose!'.colorize(color: :red, mode: :bold)
    else
      puts 'The computer could not crack your code, you won!'.colorize(color: :cyan, mode: :bold)
    end
  end
end

# class Role which is the abstraction above CodeMaker & CodeBreaker
class Role
  attr_accessor :human, :computer, :array, :current_score

  def initialize(human: false)
    @human = human
    @array = [0, 0, 0, 0]
  end

  def set_array
    @array = ask_array if human
  end

  def ask_array # rubocop:disable Metrics/MethodLength
    input = 'empty'
    n = 0
    until input.length == 4 && input.integer? && input.in_range?
      if n.zero?
        print 'Enter the 4 digit code: '.colorize(mode: :bold)
      else
        print 'Please enter 4 digits and integers from 1 to 6 only. Try again: '.colorize(mode: :bold)
      end
      input = gets.chomp
      n += 1
    end
    input.split('').map(&:to_i)
  end

  def display
    puts "#{whose_array.capitalize} #{array_name}: #{array.join('')}" if instance_of? CodeBreaker
  end

  def whose_array
    if human
      'your'
    else
      "computer's"
    end
  end

  def intro
    puts "As a #{self.class}, you have to #{role_word} a 4 digit code. \n" \
         "The code #{auxilary_verb} made of integers from 1 to 6, with duplicates allowed. \n" \
         "#{codebreaker.capitalize} have 12 chances to guess the code. Good luck! \n" \
         "\n"
  end
end

# the one that plays the role of CodeMaker
class CodeMaker < Role
  def set_array
    super
    @array = random_digits unless human
    display
  end

  def random_digits
    num_array = (1..6).to_a
    array = []
    4.times { array.push(num_array.sample) }
    array
  end

  def array_name
    'code'
  end

  def auxilary_verb
    'should be'
  end

  def codebreaker
    'the computer'
  end
  
  def role_word
    'create'
  end
end

# the one that tries to break the code; in this first case the Player
class CodeBreaker < Role
  attr_accessor :possible_guesses, :round, :guess_feedback, :integer_combo

  def initialize(human: false)
    super
    @possible_guesses = nil
    @round = 1
    @guess_feedback = [0, 0] # pos_score, int_score
    @integer_combo = []
  end

  def set_array
    super
    @array = update_array unless human
    display
  end

  def update_array
    enter_prompt
    create_permutations if integer_combo.length == 4 && possible_guesses.nil?
    if integer_combo.length < 4
      single_integer_guess
    else
      random_permutation
    end
  end

  def enter_prompt
    input = nil
    until input == "\n"
      puts 'Press enter to continue '
      input = gets
    end
  end

  def calculate
    integer_feedback = guess_feedback.sum
    integer_feedback.times { integer_combo.push(round) } if round < 6
    # the code below is to automatically fill in 6 when it is the last
    # possible integer left
    (4 - integer_combo.length).times { integer_combo.push(6) } if round == 5 && integer_combo.length != 4
    @round += 1
  end

  def single_integer_guess
    Array.new(4, round)
  end

  def create_permutations
    array = []
    integer_combo.permutation(4) { |perm| array.push(perm) }
    @possible_guesses = array.uniq
  end

  def random_permutation
    possible_guesses.delete(possible_guesses.sample)
  end

  def array_name
    'guess'
  end

  def auxilary_verb
    'are'
  end

  def codebreaker
    'you'
  end
  
  def role_word
    'crack'
  end
end

# extending String to incorporate methods specific to this game
class String
  def in_range?
    split('').map(&:to_i).all? { |int| int.between?(1, 6) }
  end

  def integer?
    to_i.positive?
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

Game.new.play
