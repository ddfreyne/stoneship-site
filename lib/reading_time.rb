module ReadingTime
  # Reading speed is 200–250 words per minute.
  # We take complexity into account though.
  WORDS_PER_MINUTE_FAST = 230
  WORDS_PER_MINUTE_SLOW = 180

  def calc(string, complexity: 0)
    num_words = string.scan(/\w+/).size

    words_per_minute =
      WORDS_PER_MINUTE_FAST * (1 - complexity) +
      WORDS_PER_MINUTE_SLOW * complexity
    num_minutes = (num_words.to_f / words_per_minute).ceil

    num_minutes
  end

  module_function :calc
end
