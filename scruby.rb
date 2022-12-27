# frozen_string_literal: true

require "zlib"
require "pry-byebug"
require "benchmark/ips"

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

class DictionaryWithHash
  def initialize
    arr = read_file.split("\n")
    @wordz = Hash.new(false)
    arr.each { |word| @wordz[word] = true }   # 2,000x faster than array lookup (3.4M lookups/sec)
  end

  def word?(word)
    @wordz[word.upcase]
  end

  private

  def read_file
    File.open("words.txt.gz") do |f|
      gz = Zlib::GzipReader.new(f)
      return gz.read
      gz.close
    end
  end
end

class Board
  class InvalidBoard < StandardError; end

  def initialize(board = EMPTY_BOARD)
    @board = board
    @dictionary = DictionaryWithHash.new

    validate_board!
  end

  def validate_words!
    words
  end

  def validate_board!
    lines = @board.split("\n")

    raise InvalidBoard.new("Wrong number of lines (#{lines.length}") unless lines.length == 15

    lines.each_with_index do |line, index|
      next if line.length == 15

      raise InvalidBoard.new("Line #{index} has #{line.length} chars (should be 15)")
    end
  end

  private

  def words
    "ok"
  end
end

puts "Ruby version: #{RUBY_VERSION}"
b1 = Board.new(BOARD_WITH_WORDS)

b1.validate_words!
