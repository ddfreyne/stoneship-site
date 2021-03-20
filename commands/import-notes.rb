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
files_path = File.expand_path(File.join(__dir__, '..', 'content', 'notes'))

run do |opts, args, cmd|
  $stderr.puts "Importing…"

  FileUtils.mkdir_p(files_path)

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
    {
      id: row[:ZUNIQUEIDENTIFIER],
      title: row[:ZTITLE],
      text: row[:ZTEXT],
      mtime: row[:zmodificationdate2]
    }
  end

  public_notes =
    notes.select do |note|
      note[:text].match?(/^(#[a-zA-Z\/]+\s+)*#public\s*$/)
    end.map do |note|
      note.merge(text: note[:text].gsub(tag_regex, ''))
    end

  public_notes.each do |note|
    $stderr.puts "  - #{note[:title].inspect}"

    meta = {
      'title' => note[:title],
      'updated_at' => Time.parse(note[:mtime])
    }
    content = note[:text].sub(/^# .*/, '')

    full_content = YAML.dump(meta) + "---\n\n" + content

    note_path = File.join(files_path, note[:id] + '.md')
    File.write(note_path, full_content)
  end

  $stderr.puts "Done"
end
