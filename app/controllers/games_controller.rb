require "json"
require "open-uri"

class GamesController < ApplicationController
  def new
    consonants = ('a'..'z').to_a - %w[a e i o u]
    vowels = %w[a e i o u]

    consonant_count = 5
    vowel_count = 5

    @letters = (consonants.sample(consonant_count) + vowels.sample(vowel_count)).shuffle
    session[:letters] = @letters
    
    @score = session[:score] || 0
  end

  def score
    @letters = session[:letters]
    @input = params[:input]
    url = "https://wagon-dictionary.herokuapp.com/#{@input}"
    info_serialized = URI.open(url).read
    word = JSON.parse(info_serialized)
    @player_score = ""
    valid_word = @input.chars.all? { |letter| @input.count(letter) <= @letters.count(letter) }

    if word['found'] == true && valid_word
      @player_score = "Congratulations! #{word['word'].capitalize} is a valid English word!"
    elsif word['found'] == true && valid_word == false
      @player_score = "Sorry, #{word['word']} is an English word but not included in the game..."
    else
      @player_score = "Sorry, but #{word['word'].downcase} is not a valid English Word..."
    end

    @score = session[:score] || 0
    @score += @input.chars.count if word['found'] == true && valid_word
    session[:score] = @score
  end
end
