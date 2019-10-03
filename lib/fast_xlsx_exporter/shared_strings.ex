defmodule FastXlsxExporter.SharedStrings do
  require EEx

  @path Path.join(["xl", "sharedStrings.xml"])

  EEx.function_from_file(:defp, :render_start, "#{__DIR__}/shared_strings/start.xml.eex", [])
  EEx.function_from_file(:defp, :render_end, "#{__DIR__}/shared_strings/end.xml.eex", [])

  EEx.function_from_file(:defp, :render_value, "#{__DIR__}/shared_strings/value.xml.eex", [:value])

  def initialize(base_path) do
    {:ok, fd} = fd(base_path)
    :file.truncate(fd)
    strings_start = render_start()
    :file.write(fd, strings_start)
    {fd, 0}
  end

  def finalize({fd, _}) do
    strings_end = render_end()
    :file.write(fd, strings_end)
    :file.close(fd)
  end

  def write_string(value, {fd, count}) when is_binary(value) do
    string = render_value(escape(value))
    :file.write(fd, string)
    {to_string(count), {fd, count + 1}}
  end

  def shared_string?(value), do: is_binary(value)

  defp fd(base_path) do
    sheet_path = Path.join(base_path, @path)
    :file.open(to_charlist(sheet_path), [:append])
  end

  defp escape(value) do
    value
    |> String.replace("&", "&amp;")
    |> String.replace("'", "&apos;")
    |> String.replace("\"", "&quot;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
    |> String.replace("\n", "")
  end
end
