# frozen_string_literal: true

require "bundler"
require "zlib"
require "benchmark/ips"
require "pry-byebug"

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
  HELLO..........
  ...............
  ...............
  ...............
  .....CAT.......
  .....A.........
  .....R.........
  ...............
  ...APPLE.PLANET
  ...............
  W..............
  A..............
  T..............
  C..............
  H..............
YAY

BOARD_WITH_INVALID_WORDS = <<~YAY
  HELLO..........
  ...............
  ...............
  ...............
  .....CAT.......
  .....A.........
  .....R.........
  ...............
  ...APPLE.PLANET
  ...............
  W.....XYZ......
  A..............
  T..............
  C..............
  H..............
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

  def to_s
    "your dad"
  end

  private

  def get_word_set(path)
    Zlib::GzipReader.new(File.open(path)).readlines.map { |x| x.gsub("\n","") }.to_set
  end
end

class Board
  BOARD_HEIGHT_WIDTH = 15

  class InvalidBoard < StandardError; end
  class InvalidWord < StandardError; end

  def initialize(board = EMPTY_BOARD)
    @board = board.gsub("\n", "")
    @dictionary = DictionarySet.new

    validate_board!
  end

  # todo
  def validate_words!
    words.each do |word|
      next if @dictionary.word?(word)

      raise InvalidWord.new("\"#{word}\" is not a valid word, pal")
    end
  end

  # Validates the "shape" of the board; i.e. it should be a 15x15 board
  def validate_board!
    return if @board.length == BOARD_HEIGHT_WIDTH**2
    raise InvalidBoard.new(
      "Wrong board size; has #{@board.length} chars but should have " \
      "#{BOARD_HEIGHT_WIDTH} * #{BOARD_HEIGHT_WIDTH} = " \
      "#{BOARD_HEIGHT_WIDTH**2} chars",
    )
  end

  # private

  def words
    lines_to_words(cols) + lines_to_words(rows)
  end

  def cols
    result = Array.new(BOARD_HEIGHT_WIDTH) { +"" } # +"" is an unfrozen string literal
    0.upto(BOARD_HEIGHT_WIDTH - 1) do |x|
      0.upto(BOARD_HEIGHT_WIDTH - 1) do |y|
        result[x] << @board[(y * BOARD_HEIGHT_WIDTH) + x]
      end
    end
    result
  end

  def rows
    @board.scan(/.{1,#{BOARD_HEIGHT_WIDTH}}/)
  end

  def lines_to_words(lines)
    lines.
      map { |x| x.split(".") }.
      flatten.
      reject { |x| x.length < 2 }
  end
end

puts "Ruby version: #{RUBY_VERSION}"
b1 = Board.new(BOARD_WITH_WORDS)
b1.validate_words!
b2 = Board.new(BOARD_WITH_INVALID_WORDS)
b2.validate_words!
