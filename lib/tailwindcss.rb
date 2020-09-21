# frozen_string_literal: true

Nanoc::Filter.define(:tailwindcss) do |content, _params = {}|
  # Set up dependencies for purgecss
  ENV['NODE_ENV'] = 'production'
  @items.find_all('/**/*.{html,dmark}').each do |item|
    item.compiled_content
  end

  Tempfile.create(['src', '.css']) do |src_file|
    File.write(src_file, content)

    Tempfile.create(['dst', '.css']) do |dst_file|
      cmd = [
        'npx',
        'tailwindcss',
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
