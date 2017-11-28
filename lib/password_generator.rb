module PasswordGenerator
  extend self

  DOWNCASES = ('a'..'z').map(&:freeze).freeze
  UPPERCASES = ('A'..'Z').map(&:freeze).freeze
  NUMBERS = ('0'..'9').map(&:freeze).freeze
  SYMBOLS = [*'!'..'/', *':'..'@', *'['..'`', *'{'..'~'].each(&:freeze).freeze

  ALL_CHARS = DOWNCASES + UPPERCASES + NUMBERS + SYMBOLS

  def generate_password(length = 64)
    lst = ALL_CHARS.sort_by{ |_| rand }
    num_chars = lst.length

    length.times.map { lst[SecureRandom.random_number(num_chars)] }.join
  end
end
