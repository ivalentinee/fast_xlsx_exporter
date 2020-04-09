defmodule FastXlsxExporter.SharedStrings do
  @moduledoc false

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
    count = 0
    dictionary = %{}
    {fd, count, dictionary}
  end

  def finalize({fd, _, _}) do
    strings_end = render_end()
    :file.write(fd, strings_end)
    :file.close(fd)
  end

  def write_string({value, :dictionary}, {fd, count, dictionary}) when is_binary(value) do
    if index = dictionary[value] do
      {index, {fd, count, dictionary}}
    else
      write_shared_string(value, fd)
      new_dictionary = Map.put(dictionary, value, to_string(count))
      {to_string(count), {fd, count + 1, new_dictionary}}
    end
  end

  def write_string({value, _}, {fd, count, dictionary}) when is_binary(value) do
    write_shared_string(value, fd)
    {to_string(count), {fd, count + 1, dictionary}}
  end

  def shared_string?({value, _format}), do: is_binary(value)

  defp write_shared_string(value, fd) do
    string = render_value(escape(value))
    :file.write(fd, string)
  end

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
