Class.new(Nanoc::Filter) do
  identifier :resize
  type :binary => :binary

  def run(filename, params = {})
    system('sips', '--resampleWidth', params.fetch(:width).to_s, '--out', output_filename, filename)
  end
end
