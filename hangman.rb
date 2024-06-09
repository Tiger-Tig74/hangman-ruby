# frozen_string_literal: true

# Hangman is a command-line game where one player plays against the computer
# to guess a secret word within a limited number of attempts.
class Hangman
  attr_accessor :secret_word, :guessed_letters, :incorrect_guesses, :max_attempts

  def initialize(game_data = nil)
    @dictionary = File.readlines('google-10000-english-no-swears.txt').map(&:chomp)
    if game_data
      @guessed_letters = game_data[:guessed_letters]
      @secret_word = game_data[:secret_word]
      @incorrect_guesses = game_data[:incorrect_guesses]
      @max_attempts = game_data[:max_attempts]
    else
      @secret_word = generate_secret_word
      @guessed_letters = []
      @incorrect_guesses = 0
      @max_attempts = 8
    end
  end

  def generate_secret_word
    @dictionary.select { |word| word.length.between?(5, 12) }.sample.downcase
  end

  def display_word
    displayed_word = ''
    @secret_word.chars.each do |char|
      displayed_word += if @guessed_letters.include?(char)
                          char
                        else
                          '_'
                        end
    end
    displayed_word
  end

  def display_guessed_letters
    @guessed_letters.join(', ')
  end

  def play
    puts 'Welcome to Hangman!'
    puts "Word: #{display_word}"
    puts "Guessed letters: #{display_guessed_letters}"

    loop do
      puts "\nMake a guess or type 'save' to save the game:"
      guess = gets.chomp.downcase

      if guess == 'save'
        save_game
        break
      elsif guess.length != 1 || !guess.match?(/[a-z]/)
        puts 'Invalid input. Please guess a single letter.'
        next
      elsif @guessed_letters.include?(guess)
        puts "You've already guessed that letter!"
        next
      end

      @guessed_letters << guess

      if @secret_word.include?(guess)
        puts 'Correct guess!'
      else
        @incorrect_guesses += 1
        puts "Incorrect guess! You have #{@max_attempts - @incorrect_guesses} attempts left."
      end

      puts "Word: #{display_word}"
      puts "Guessed letters: #{display_guessed_letters}"

      if @secret_word.chars.all? { |char| @guessed_letters.include?(char) }
        puts "Congratulations, you've guessed the word!"
        break
      elsif @incorrect_guesses == @max_attempts
        puts "Sorry, you're out of attempts. The word was #{@secret_word}."
        break
      end
    end
  end

  def save_game
    game_data = {
      guessed_letters: @guessed_letters,
      incorrect_guesses: @incorrect_guesses,
      max_attempts: @max_attempts,
      secret_word: @secret_word
    }

    File.open('saved_game.txt', 'w') { |file| file.write(Marshal.dump(game_data)) }
    puts 'Game saved successfully.'
  end

  def self.load_game
    if File.exist?('saved_game.txt')
      saved_game = File.read('saved_game.txt')
      game_data = Marshal.load(saved_game)
      Hangman.new(game_data).play
    else
      puts 'No saved game found.'
      run
    end
  end
end

def run
  loop do
    puts "Would you like to start a new game or load a saved game? (Type 'new' or 'load')"
    option = gets.chomp.downcase

    if option == 'new'
      game = Hangman.new
      game.play
      break
    elsif option == 'load'
      Hangman.load_game
      break
    else
      puts "Invalid option. Please type 'new' or 'load'."
      next
    end
  end
end

run
