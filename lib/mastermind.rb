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

until guess == code
  12.times do |n|
    puts '-----------------------------------------------------'
    puts "Row #{n + 1}"
    puts '-----------------------------------------------------'
    p code
    take_input(guess)
    break if guess == code
  end
end
