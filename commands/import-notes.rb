require 'sequel'

usage       'import-notes [options]'
summary     'import notes from Bear'
description 'Imports public notes from Bear'

flag   :h, :help,  'show help for this command' do |value, cmd|
  puts cmd.help
  exit 0
end

db_path = "#{Dir.home}/Library/Group Containers/9K33E3U3T4.net.shinyfrog.bear/Application Data/database.sqlite"
tag_regex = /^#[a-zA-Z\/]+(\s+#[a-zA-Z\/]+)*\s*/
notes_files_path = File.expand_path(File.join(__dir__, '..', 'content', 'notes'))
fiction_files_path = File.expand_path(File.join(__dir__, '..', 'content', 'fiction'))

run do |opts, args, cmd|
  $stderr.puts "Importing…"

  FileUtils.mkdir_p(notes_files_path)
  FileUtils.mkdir_p(fiction_files_path)

  db = Sequel.connect(adapter: :sqlite, database: db_path, readonly: true)

  # Core Data timestamps are stored as seconds offset from beginning of 2001.
  query = <<~QUERY
    SELECT
      *,
      datetime(zmodificationdate, 'unixepoch', '31 years') AS zmodificationdate2
    FROM
      zsfnote
    WHERE
      ztrashed == 0 AND zarchived == 0
  QUERY
  notes = db[query].map do |row|
    raw_tags = row[:ZTEXT][/^(#[a-zA-Z\/]+\s+)*#public(\s+#[a-zA-Z\/]+)*$/] || ''
    tags = raw_tags.split(/\s+/)

    {
      id: row[:ZUNIQUEIDENTIFIER],
      title: row[:ZTITLE],
      text: row[:ZTEXT],
      mtime: row[:zmodificationdate2],
      tags: tags
    }
  end

  public_notes = notes.select { |n| n.fetch(:tags, []).include?('#public') }

  public_notes.each do |note|
    $stderr.puts "  - #{note[:title].inspect}"

    tagless_text = note[:text].gsub(tag_regex, '')
    is_fiction = note.fetch(:tags, []).include?('#fiction')

    meta = {
      'title' => note[:title],
      'updated_at' => Time.parse(note[:mtime]),
      'tags' => note[:tags]
    }
    content = tagless_text.sub(/^# .*/, '') # remove first heading

    full_content = YAML.dump(meta) + "---\n\n" + content

    base_path = is_fiction ? fiction_files_path : notes_files_path
    path = File.join(base_path, note[:id] + '.md')

    File.write(path, full_content)
  end

  $stderr.puts "Done"
end
