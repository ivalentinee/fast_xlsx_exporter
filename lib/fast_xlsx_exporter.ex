defmodule FastXlsxExporter do
  alias FastXlsxExporter.Sheet

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

  def put_row(row, {dir, sheet_context}) when is_list(row) do
    {dir, Sheet.write_row(row, sheet_context)}
  end

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
