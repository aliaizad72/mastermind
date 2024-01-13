# frozen_string_literal: true

# There are 6 possible colours in the game
colours = (1..6).to_a
# In each game, 4 SPOTS are filled with colours, duplicates allowed
code = []
4.times { code.push(colours.sample) }

guess = []
# Take guesses from user
def take_input(guess)
  4.times do |index|
    puts "Your guess for the #{index + 1} spot: "
    guess[index] = gets.chomp
  end
  guess
end

until cracked?(code, guess)
  12.times do
    take_input(guess)
  end
end

# Check if guesses match the code
def cracked?(code, guess)
  return true if guess == code

  false
end

