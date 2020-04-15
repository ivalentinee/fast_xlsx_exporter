defmodule FastXlsxExporter do
  @moduledoc """
  # Fast XLSX Exporter

  ## Installation

  Add `fast_xlsx_exporter` to your mix.ex deps:

  ```elixir
  def deps do
    [
      {:fast_xlsx_exporter, "~> 0.2.0"}
    ]
  end
  ```

  ## Explanation

  [Elixlsx](https://github.com/xou/elixlsx) was fine, until really huge exports appeared. Then it took more and more time to generate xlsx reports. And RAM.

  So, being really primitive (8 hour at night from scratch knowing nothing about xlsx) this library does not store document in memory. It writes straight to file system.

  Some example:
  ```elixir
  rows = [[1, 2, 3, 10], [4, 5, 6], [7, 8, 9]]

  context = FastXlsxExporter.initialize()
  context = Enum.reduce(rows, context, &FastXlsxExporter.put_row/2)
  {:ok, {_filename, document}} = FastXlsxExporter.finalize(context)
  File.write("/home/george/failures.xlsx", document)
  ```

  See? Really simple thing, nothing special.

  If you're looking for something that really supports xlsx, go with [elixlsx](https://github.com/xou/elixlsx).

  ## Supported cell values

  ### Numbers
  Both `float` and `integer` values are supported and special form of `{<float>, :percents}` to write number as xlsx percent.

  Example row:
  ```elixir
  [1, 12.5, {0.59, :percents}]
  ```

  ### Strings
  Strings could be written in two ways.

  First one is straight (no special form). In this case strings are written sequentially to **shared strings**, which is RAM-friendly but bloats resulting xlsx file.

  Second one requires special form of `{<string>, :dictionary}`. In this case strings are put into dictionary and are put into **shared strings** only once, but are stored in memory, which is good for limited set of values but can cause `OOMKilled` if strings are *random*.

  Example rows:
  ```elixir
  # first row
  ["Vladimir Putin", "Donald Trump", "Literally Hitler"]
  # second row
  [{"some_string", :dictionary}, {"some_other_string", :dictionary}, {"some_string", :dictionary}]
  # third row
  ["wow!", {"some_other_string", :dictionary}, "yay!"]
  ```

  ### Date and time
  Both `%Date{}` and `%NaiveDateTime{}` are rendered as dates (not strings).

  Example row:
  ```elixir
  [~D[1905-12-11], ~D[2020-04-09], ~N[2020-04-09 12:00:00]]
  ```
  """

  alias FastXlsxExporter.Sheet

  @type context() :: {binary(), Sheet.context()}

  @doc """
  Initializes export

  Creates temporary export directory at `System.tmp_dir!()`, writes common files and content file header
  """
  @spec initialize() :: context()
  def initialize do
    :random.seed()
    temp_name = "xlsx_#{:rand.uniform(1_000_000_000)}"
    dir = Path.join(System.tmp_dir!(), temp_name)
    File.rm_rf!(dir)
    File.mkdir!(dir)
    FastXlsxExporter.Sample.write(dir)
    sheet_context = Sheet.initialize(dir)

    {dir, sheet_context}
  end

  @doc """
  Adds row to document
  """
  @spec put_row(Sheet.row(), context()) :: context()
  def put_row(row, {dir, sheet_context}) when is_list(row) do
    {dir, Sheet.write_row(row, sheet_context)}
  end

  @doc """
  Finalizes export

  Removes temporary directory, closes file descriptors
  """
  @spec finalize(context()) :: {:ok, binary()} | {:error, reason :: charlist()}
  def finalize({dir, sheet_context}) do
    Sheet.finalize(sheet_context)
    archive = :zip.create("file.xlsx", list_files(dir), [:memory, cwd: to_charlist(dir)])
    File.rm_rf!(dir)

    case archive do
      {:ok, {_filename, content}} -> {:ok, content}
      error -> error
    end
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
