defmodule FastXlsxExporter.XlsxReader do
  @moduledoc false
  @temp_files_dir "xlsx_exporter_temp_dir"

  def read_file(filename) do
    Application.ensure_all_started(:xlsxir)
    {:ok, xlsxir_table} = Xlsxir.multi_extract(filename, 0, false, nil, extract_to: :memory)
    Xlsxir.get_list(xlsxir_table)
  end

  def read_document(document) do
    create_temp_file_dir()
    filename = write_file(document)
    document = read_file(filename)
    delete_file(filename)
    document
  end

  def create_temp_file_dir do
    File.mkdir_p!(temp_file_dir_path())
  end

  def remove_temp_file_dir do
    File.rm_rf!(temp_file_dir_path())
  end

  def random_file_path do
    Path.join(temp_file_dir_path(), random_filename())
  end

  def delete_file(filename) do
    File.rm_rf!(filename)
  end

  defp write_file(document) do
    filename = random_file_path()
    File.write!(filename, document)
    filename
  end

  defp random_filename do
    "#{:rand.uniform(10_000)}.xlsx"
  end

  def temp_file_dir_path do
    Path.join(System.tmp_dir!(), @temp_files_dir)
  end
end
