# frozen_string_literal: true

require "bundler"
require "zlib"
require "benchmark/ips"
# require "pry-byebug"

EMPTY_BOARD = <<~SCRABBLE
  ...............
  ...............
  ...............
  ...............
  ...............
  ...............
  ...............
  ...............
  ...............
  ...............
  ...............
  ...............
  ...............
  ...............
  ...............
SCRABBLE

BOARD_WITH_WORDS = <<~YAY
  ...............
  ...............
  ...............
  ...............
  .....CAT.......
  ...............
  ...............
  ...............
  ...APPLE.PLANET
  ...............
  ...............
  ...............
  ...............
  ...............
  ...............
YAY

class DictionarySet
  PATH_TO_FULL_DICT = "words.txt.gz"
  PATH_TO_PARTIAL_DICT = "1000words.txt.gz"

  def initialize
    @all_words = get_word_set(PATH_TO_FULL_DICT)
  end

  def word?(word)
    @all_words.include?(word.upcase)
  end

  # 3.4M lookups/sec with Ruby 3.2, or 4.1M lookups/sec with Ruby 3.2+YJIT (2.6ghz i7)
  def bench
    some_words = get_word_set(PATH_TO_PARTIAL_DICT).to_a

    Benchmark.ips do |bm|
      bm.config(time: 5, warmup: 3)
      bm.report("DictionarySet word lookups") do
        word?(some_words.sample)
      end
    end
  end

  private

  def get_word_set(path)
    Zlib::GzipReader.new(File.open(path)).readlines.to_set
  end
end

class Board
  BOARD_HEIGHT_WIDTH = 15

  class InvalidBoard < StandardError; end

  def initialize(board = EMPTY_BOARD)
    @board = board
    @dictionary = DictionarySet.new

    validate_board!
  end

  # todo
  def validate_words!
    true
  end

  # Validates the "shape" of the board; i.e. it should be a 15x15 board
  def validate_board!
    lines = @board.split("\n")

    unless lines.length == BOARD_HEIGHT_WIDTH
      raise InvalidBoard.new("Wrong number of lines (#{lines.length}")
    end

    lines.each_with_index do |line, index|
      next if line.length == BOARD_HEIGHT_WIDTH

      raise InvalidBoard.new(
        "Line #{index} has #{line.length} chars (should be #{BOARD_HEIGHT_WIDTH})",
      )
    end
  end

  private

  def words
    "ok"
  end
end

puts "Ruby version: #{RUBY_VERSION}"
b1 = Board.new(BOARD_WITH_WORDS)

d1 = DictionarySet.new.bench
