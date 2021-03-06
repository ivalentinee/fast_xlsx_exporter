defmodule FastXlsxExporter.Sheet do
  @moduledoc nil

  require EEx
  import FastXlsxExporter.Sheet.ColumnIds
  alias FastXlsxExporter.SharedStrings
  alias FastXlsxExporter.Sheet.Cell
  alias FastXlsxExporter.Styles
  alias FastXlsxExporter.Utils

  @path Path.join(["xl", "worksheets", "sheet1.xml"])

  @type context() :: {{:file.io_device(), integer()}, SharedStrings.shared_strings_context()}
  @type cell() ::
          binary()
          | number()
          | {number(), :percents}
          | {binary(), :dictionary}
          | %Date{}
          | %NaiveDateTime{}
  @type row() :: list(cell())

  EEx.function_from_file(:defp, :render_row, "#{__DIR__}/sheet/row.xml.eex", [:index, :content])
  EEx.function_from_file(:defp, :render_start, "#{__DIR__}/sheet/start.xml.eex", [])
  EEx.function_from_file(:defp, :render_end, "#{__DIR__}/sheet/end.xml.eex", [])

  @doc false
  @spec initialize(binary()) :: {:ok, context()}
  def initialize(base_path) do
    {:ok, fd} = Utils.open_new_file(base_path, @path)
    {:ok, shared_strings_context} = SharedStrings.initialize(base_path)
    sheet_start = render_start()
    :file.write(fd, sheet_start)
    Styles.write(base_path)
    written_row_count = 0
    context = {{fd, written_row_count}, shared_strings_context}
    {:ok, context}
  end

  @doc false
  @spec finalize(context()) :: any()
  def finalize({{fd, _row_count}, shared_strings_context}) do
    sheet_end = render_end()
    :file.write(fd, sheet_end)
    :file.close(fd)
    SharedStrings.finalize(shared_strings_context)
  end

  @doc false
  @spec write_row(row(), context()) :: context()
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

  defp write_cell(
         row_number,
         {{value, format}, column_index},
         {row_string, shared_strings_context}
       ) do
    if value && value != "" do
      if SharedStrings.shared_string?({value, format}) do
        {value, new_shared_string_context} =
          SharedStrings.write_string({value, format}, shared_strings_context)

        {
          row_string <> cell(row_number, column_index, {value, format}),
          new_shared_string_context
        }
      else
        {
          row_string <> cell(row_number, column_index, {value, format}),
          shared_strings_context
        }
      end
    else
      {row_string, shared_strings_context}
    end
  end

  defp write_cell(row_number, {value, column_index}, context) do
    write_cell(row_number, {{value, nil}, column_index}, context)
  end

  defp cell(row_index, column_index, value) do
    id = id(row_index, column_index)
    Cell.render(id, value)
  end

  defp id(row_index, column_index) do
    "#{Enum.at(column_ids(), column_index - 1)}#{row_index}"
  end
end
