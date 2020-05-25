require 'yaml'
require 'pathname'

class Game
  attr_accessor :word, :num_guesses, :board, :letter, :incorrect_letters, :guessed_letters

  def initialize
    @word = choose_word.downcase
    @letter = "_ "
    @board = Array.new(self.word.length, self.letter)
    @num_guesses = self.word.chars.uniq.length + 3
    @incorrect_letters = []
    @guessed_letters = []
  end

  def choose_word
    words = File.readlines("5desk.txt", chomp: true)
    word_between_5_and_12 = words.select { |word| word.length > 5 && word.length < 12 }
    word = word_between_5_and_12.sample.downcase
  end

  def display_board(word, letter, board)
    if self.guessed_letters.include?(letter)
      puts "You've already guessed the letter #{letter}!\n\n"
    elsif self.word.downcase.chars.include?(letter)
      self.board = self.board.each_with_index.map { |val, i| self.word[i] == letter ? "#{letter} " : val }
      self.guessed_letters.push(letter)
      puts "Good guess! The word contains the letter #{letter}\n\n"
    elsif !self.word.downcase.chars.include?(letter) && letter != "_ "
      puts "The word does not contain the letter #{letter}!\n\n"
      self.incorrect_letters.push(letter)
    end
    puts self.board.join
    puts ""
    return self.board
  end

  def guess_letter
    letter_guess = ""
    loop do
      print "Guess a letter from a-z! ---> "
      letter_guess = gets.chomp.downcase
      break if letter_guess.length == 1 && ('a'..'z').to_a.include?(letter_guess)
    end
    letter_guess
  end

  def ask_to_save_game
    print "Would you like to save your game (y/n)? "
    save_or_not = gets.chomp
    puts ""
    return if save_or_not != "y"
    serialised_object = YAML::dump({
      :word => @word,
      :num_guesses => @num_guesses,
      :board => @board,
      :letter => @letter,
      :incorrect_letters => @incorrect_letters,
      :guessed_letters => @guessed_letters
    })
    file = File.new("saved_game.yaml", "w")
    file.write(serialised_object)
    print "Game saved! Would you like to exit the game (y/n)? "
    exit_or_not = gets.chomp
    puts ""
    return "exit" if exit_or_not == "y" 
  end

  def ask_to_load_game
    print "Would you like to load your game (y/n)? "
    response = gets.chomp
    puts ""
    return if response != "y"
    serialised_object = File.read("saved_game.yaml")
    file = YAML::load(serialised_object)
    self.word = file[:word] 
    self.num_guesses = file[:num_guesses]
    self.board = file[:board]
    self.letter = file[:letter]
    self.incorrect_letters = file[:incorrect_letters]
    self.guessed_letters = file[:guessed_letters]
  end

  def ask_if_saved_exists
    path = Pathname.new("saved_game.yaml")
    if path.exist?
      ask_to_load_game
    end
  end

  def play 
    puts "Welcome to Hangman!\n\n"

    ask_if_saved_exists
    puts self.word 

    (self.num_guesses + 1).times do |index|
      self.board = display_board(self.word, self.letter, self.board)
      if self.board.join.gsub(/\s+/, "") == self.word
        puts "Congratulations, you win!"
        puts "The word was \"#{self.word}\"!\n\n"
        break
      elsif index == self.num_guesses
        puts "Sorry, you're out of guesses! You lose!"
        puts "The word was \"#{self.word}\"!\n\n"
        break
      end
      break if ask_to_save_game == "exit"
      puts "Incorrect letters so far: #{self.incorrect_letters.uniq.join(", ")}\n\n"
      self.letter = guess_letter
    end
  end

  def to_s
    "In Game:" 
  end
end

game = Game.new
game.play
