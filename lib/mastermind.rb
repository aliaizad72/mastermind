# frozen_string_literal: true

# There are 6 possible colours in the game
colours = (1..6).to_a
# In each game, 4 SPOTS are filled with colours, duplicates allowed
code = []
4.times { code.push(colours.sample) }

guess = Array.new(4, 0)
# Take guesses from user
def take_input(guess)
  4.times do |index|
    puts "Current guess: #{guess}"
    print "Your guess for the #{index + 1} spot: "
    # If input is empty/default, no change to the index value
    input = gets.chomp.to_i
    if input.zero?
      puts "No change in value. Guess: #{guess}"
      puts
      next
    end
    guess[index] = input
    puts "Guess after input: #{guess}"
    puts
  end
end

def correct_position(code, guess)
  correct_pos_count = 0

  code.each_with_index do |color, index|
    correct_pos_count += 1 if color == guess[index]
  end
  correct_pos_count
end

def correct_color(code, guess)
  color_count = code.each_with_object({}) { |color, hash| hash[color] = code.count(color) }

  guess_in_code = guess.select { |color| code.include?(color) }
  guess_in_code_count = guess_in_code.each_with_object({}) { |color, hash| hash[color] = guess_in_code.count(color) }

  correct_color_hash = {}
  guess_in_code_count.each_pair do |key, value|
    correct_color_hash[key] = if value < color_count[key]
                                value
                              else
                                color_count[key]
                              end
  end

  correct_color_hash.values.sum
end

until guess == code
  12.times do |n|
    puts '-----------------------------------------------------'
    puts "Row #{n + 1}"
    puts '-----------------------------------------------------'
    p code
    take_input(guess)
    puts "#{correct_position(code, guess)} guess are in the right place."
    puts "#{correct_color(code, guess)} color guess are correct."
    break if guess == code
  end
end
