# frozen_string_literal: true

def handle_error(e, content)
  case e
  when DMark::Parser::ParserError
    line = content.lines[e.line_nr]

    lines = [
      e.message,
      '',
      line,
      "\e[31m" + ' ' * [e.col_nr - 1, 0].max + '↑' + "\e[0m",
    ]

    fancy_msg = lines.map { |l| "\e[34m[D*Mark]\e[0m #{l.rstrip}\n" }.join('')
    raise "D*Mark parser error\n\n" + fancy_msg
  else
    raise e
  end
end
