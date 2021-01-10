# frozen_string_literal: true

class TailwindConfig < ::Nanoc::DataSource
  identifier :tailwind_config

  def items
    [
      new_item(
        File.read('tailwind.config.js'),
        {},
        '/ignore/tailwind.config.js'
      )
    ]
  end
end

Nanoc::Filter.define(:tailwindcss) do |content, _params = {}|
  # Set up dependencies for purgecss
  ENV['NODE_ENV'] = 'production'
  @items.find_all('/**/*.{html,dmark,md}').each do |item|
    item.compiled_content
  end

  # Set up dependency on tailwind.config.js
  @items['/ignore/tailwind.config.js'].raw_content

  Tempfile.create(['src', '.css']) do |src_file|
    File.write(src_file, content)

    Tempfile.create(['dst', '.css']) do |dst_file|
      cmd = [
        'npx',
        'tailwindcss-cli@latest',
        'build',
        src_file.path,
        '-o',
        dst_file.path,
        '--config',
        'tailwind.config.js'
      ]

      command = TTY::Command.new(printer: :null)
      command.run(*cmd, input: '').out

      File.read(dst_file)
    end
  end
end
