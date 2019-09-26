defmodule FastXlsxExporter.Sheet do
  require EEx
  import FastXlsxExporter.Sheet.ColumnIds
  alias FastXlsxExporter.{SharedStrings, Styles}

  @path Path.join(["xl", "worksheets", "sheet1.xml"])
  @seconds_per_day 86400

  EEx.function_from_file(:defp, :render_row, "#{__DIR__}/sheet/row.xml.eex", [:index, :content])
  EEx.function_from_file(:defp, :render_cell, "#{__DIR__}/sheet/cell.xml.eex", [:id, :value, :style, :type])
  EEx.function_from_file(:defp, :render_start, "#{__DIR__}/sheet/start.xml.eex", [:dimensions])
  EEx.function_from_file(:defp, :render_end, "#{__DIR__}/sheet/end.xml.eex", [])

  def initialize(base_path, head, count) do
    {:ok, fd} = fd(base_path)
    :file.truncate(fd)
    top_left = "A1"
    bottom_right = id(count, Enum.count(head))
    dimensions = "#{top_left}:#{bottom_right}"
    sheet_start = render_start(dimensions)
    :file.write(fd, sheet_start)
    shared_strings_context = SharedStrings.initialize(base_path)
    Styles.write(base_path)
    context = {{fd, 0}, shared_strings_context}
    write_row(head, context)
  end

  def finalize({{fd, _row_count}, shared_strings_context}) do
    sheet_end = render_end()
    :file.write(fd, sheet_end)
    :file.close(fd)
    SharedStrings.finalize(shared_strings_context)
  end

  def write_row(values, {{fd, row_count}, shared_strings_context}) do
    new_row_number = row_count + 1

    {row_content, shared_strings_context} =
      values
      |> Enum.with_index(1)
      |> Enum.reduce({"", shared_strings_context}, &write_cell(new_row_number, &1, &2))

    row = render_row(new_row_number, row_content)

    :file.write(fd, row)
    {{fd, new_row_number}, shared_strings_context}
  end

  defp write_cell(row_number, {{value, format}, column_index}, {content, shared_strings_context}) do
    if value && value != "" do
      if SharedStrings.shared_string?(value) do
        {value, new_shared_string_context} =
          SharedStrings.write_string(value, shared_strings_context)

        {
          content <> cell(row_number, column_index, {value, format}),
          new_shared_string_context
        }
      else
        {
          content <> cell(row_number, column_index, {value, format}),
          shared_strings_context
        }
      end
    else
      {content, shared_strings_context}
    end
  end

  defp write_cell(row_number, {value, column_index}, context) do
    write_cell(row_number, {{value, nil}, column_index}, context)
  end

  defp cell(row_index, column_index, value) do
    id = id(row_index, column_index)
    render_cell(id, format(value), style(value), type(value))
  end

  defp fd(base_path) do
    sheet_path = Path.join(base_path, @path)
    :file.open(to_charlist(sheet_path), [:append])
  end

  defp id(row_index, column_index) do
    "#{Enum.at(column_ids(), column_index - 1)}#{row_index}"
  end

  defp format({value, _}) when is_number(value), do: value
  defp format({value, _}) when is_binary(value), do: value
  defp format({%Date{} = value, _}), do: Date.diff(~D[1899-12-30], value)

  defp format({%NaiveDateTime{} = value, _}) do
    date = NaiveDateTime.to_date(value)
    date_chunk = Date.diff(date, ~D[1899-12-30])
    time = Time.diff(~T[00:00:00], NaiveDateTime.to_time(value))
    time_chunk = time / @seconds_per_day

    date_chunk + time_chunk
  end

  defp style({value, :percents}) when is_number(value), do: 1
  defp style({value, _}) when is_number(value), do: 0
  defp style({value, _}) when is_binary(value), do: 0
  defp style({%Date{}, _}), do: 2
  defp style({%NaiveDateTime{}, _}), do: 3

  defp type({value, _}) when is_number(value), do: "n"
  defp type({value, _}) when is_binary(value), do: "s"
  defp type({%Date{}, _}), do: "n"
  defp type({%NaiveDateTime{}, _}), do: "n"
end
