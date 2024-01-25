# frozen_string_literal: true

# Human, not yet open to other roles, only for codebreaker
class Human
  attr_accessor :digit_array
  attr_reader :role

  def initialize(role)
    @role = role.new
    @digit_array = Array.new(4, 0)
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

  def update_digit_array
    @digit_array = ask_code.split('').map(&:to_i)
    display
  end

  def display
    puts "Your #{role.array_name}: #{digit_array.join('')}"
  end
end

# class Computer for Player's opponent
class Computer
  attr_accessor :digit_array
  attr_reader :role

  def initialize(role)
    @role = role.new
    @digit_array = update_digit_array
  end

  def update_digit_array
    role.random_digits if role.is_a? CodeMaker
  end
end

# the one that plays the role of CodeMaker
class CodeMaker
  attr_reader :array_name

  def initialize
    @array_name = 'code'
  end

  def random_digits
    digits = (1..6).to_a
    sample_digits = []
    4.times { sample_digits.push(digits.sample) }
    sample_digits
  end

  def intro
    puts 'Welcome to Mastermind. As a CodeMaker, your role is simple, enter a 4 digit number (1 to 6) as your code.'
    puts 'Duplicate numbers are allowed. Good luck.'
    puts
  end
end

# the one that tries to break the code; in this first case the Player
class CodeBreaker
  attr_reader :array_name

  def initialize
    @array_name = 'guess'
  end

  def intro
    puts 'Welcome to Mastermind. In this game, you will have to crack a 4 digit code (1 to 6) set by the computer.'
    puts 'You have 12 chances to guess the code. Get crackin.'
    puts
  end
end

# controlling game flows from here
class Game
  attr_accessor :computer, :human

  def initialize
    assign_role
  end

  def assign_role
    roles = [CodeMaker, CodeBreaker]

    human_role = roles.delete(ask_role)
    computer_role = roles[0]

    @human = Human.new(human_role)
    @computer = Computer.new(computer_role)
  end

  def ask_role
    input = '0'
    i = 0

    until %w[1 2].include?(input)
      print 'Enter 1 to be the CodeMaker, or enter 2 to be the CodeBreaker: ' if i.zero?
      print 'Please enter 1 or 2 only! Try again: ' if i.positive?
      input = gets.chomp
      i += 1
    end
    return CodeMaker if input == '1'

    CodeBreaker if input == '2'
  end

  def play
    human.role.intro
    if human.role.is_a? CodeMaker
      play_codemaker
    else
      play_codebreaker
    end
  end

  def play_codemaker
    
  end

  def play_codebreaker
    i = 1
    until i > 12 || all_correct?
      puts "Round #{i}"
      human.update_digit_array
      feedback
      puts
      i += 1
    end
  end

  def all_correct?
    human.digit_array == computer.digit_array
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

    computer.digit_array.each_with_index do |digit, index|
      correct_pos_count += 1 if digit == human.digit_array[index]
    end

    correct_pos_count
  end

  def count_correct_digit
    correct_digit_count = 0
    digits_in_code_and_guess = human.digit_array.select { |digit| computer.digit_array.include?(digit) }.uniq

    digits_in_code_and_guess.each do |digit|
      digit_count_in_code = computer.digit_array.count(digit)
      digit_count_in_guess = human.digit_array.count(digit)

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
