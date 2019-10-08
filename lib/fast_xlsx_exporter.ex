defmodule FastXlsxExporter do
  @moduledoc """
  # Fast XLSX Exporter

  [Elixlsx](https://github.com/xou/elixlsx) was fine, until really huge exports appeared. Then it took more and more time to generate xlsx reports. And RAM.

  So, being really primitive (8 hour at night from scratch knowing nothing about xlsx) this library does not store document in memory. It writes straight to file system.

  Some example:
  ```elixir
  head = ["column1", "column2", "column3"]
  rows = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
  count = Enum.count(rows)

  context = FastXlsxExporter.initialize(count, head)
  context = Enum.reduce(rows, context, &FastXlsxExporter.put_row/2)
  FastXlsxExporter.finalize(context)
  ```

  See? Really simple thing, nothing special.

  If you're looking for something that really supports xlsx, go with [elixlsx](https://github.com/xou/elixlsx).
  """

  alias FastXlsxExporter.Sheet

  @type context() :: any()
  @type cell() :: binary() | number() | {number(), :percent}
  @type row() :: list(cell())
  @type filename() :: charlist()
  @type file() :: binary()

  @doc """
  Initializes export

  Creates temporary export directory at `System.tmp_dir!()`, writes common files and content file header
  """
  @spec initialize(integer(), list(binary)) :: context()
  def initialize(count, head) do
    :random.seed()
    temp_name = "xlsx_#{:rand.uniform(1_000_000_000)}"
    dir = Path.join(System.tmp_dir!(), temp_name)
    File.rm_rf!(dir)
    File.mkdir!(dir)
    FastXlsxExporter.Sample.write(dir)
    sheet_context = Sheet.initialize(dir, head, count)

    {dir, sheet_context}
  end

  @doc """
  Adds row to document
  """
  @spec put_row(row(), context()) :: context()
  def put_row(row, {dir, sheet_context}) when is_list(row) do
    {dir, Sheet.write_row(row, sheet_context)}
  end

  @doc """
  Finalizes export

  Removes temporary directory, closes file descriptors
  """
  @spec finalize(context()) :: {:ok, filename(), file()} | {:error, reason :: charlist()}
  def finalize({dir, sheet_context}) do
    Sheet.finalize(sheet_context)
    archive = :zip.create("file.xlsx", list_files(dir), [:memory, cwd: to_charlist(dir)])
    File.rm_rf!(dir)
    archive
  end

  defp list_files(path) do
    path
    |> Path.join("*")
    |> Path.wildcard()
    |> Enum.map(&String.replace_leading(&1, path, ""))
    |> Enum.map(&String.replace_leading(&1, "/", ""))
    |> Enum.map(&to_charlist/1)
  end
end
