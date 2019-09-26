defmodule FastXlsxExporter.Styles do
  require EEx

  @path Path.join(["xl", "styles.xml"])

  EEx.function_from_file(:defp, :render_styles, "#{__DIR__}/styles/styles.xml.eex", [])

  def write(base_path) do
    {:ok, fd} = fd(base_path)
    :file.truncate(fd)
    content = render_styles()
    :file.write(fd, content)
    :file.close(fd)
  end

  defp fd(base_path) do
    sheet_path = Path.join(base_path, @path)
    :file.open(to_charlist(sheet_path), [:append])
  end
end
