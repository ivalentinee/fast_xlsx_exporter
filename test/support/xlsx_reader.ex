defmodule FastXlsxExporter.XlsxReader do
  @moduledoc false
  @temp_files_dir "xlsx_exporter_temp_dir"

  def read_document(document) do
    Application.ensure_all_started(:xlsxir)
    create_temp_file_dir()
    filename = write_file(document)
    {:ok, xlsxir_table} = Xlsxir.multi_extract(filename, 0, false, nil, extract_to: :memory)
    delete_file(filename)
    Xlsxir.get_list(xlsxir_table)
  end

  defp create_temp_file_dir do
    File.mkdir_p!(temp_file_dir_path())
  end

  defp write_file(document) do
    filename = Path.join(temp_file_dir_path(), random_filename())
    File.write!(filename, document)
    filename
  end

  defp delete_file(filename) do
    File.rm_rf!(filename)
  end

  defp random_filename do
    "#{:rand.uniform(10_000)}.xlsx"
  end

  def temp_file_dir_path do
    Path.join(System.tmp_dir!(), @temp_files_dir)
  end
end
