# NOTE: Have to rely on xlsxir for tests
defmodule FastXlsxExporterTest do
  use ExUnit.Case

  alias FastXlsxExporter.XlsxReader

  setup do
    XlsxReader.create_temp_file_dir()
    on_exit(fn -> XlsxReader.remove_temp_file_dir() end)
  end

  test "writes strings to document" do
    first_row = ["value 1", "value 2", "value 3"]
    second_row = ["value 4", "value 5"]

    context = FastXlsxExporter.initialize()
    context = FastXlsxExporter.put_row(first_row, context)
    context = FastXlsxExporter.put_row(second_row, context)
    {:ok, document} = FastXlsxExporter.finalize(context)

    rows = XlsxReader.read_document(document)
    assert 2 = Enum.count(rows)
    assert first_row == Enum.at(rows, 0)
    assert second_row == Enum.at(rows, 1)
  end

  test "writes strings to file" do
    first_row = ["value 1", "value 2", "value 3"]
    second_row = ["value 4", "value 5"]

    context = FastXlsxExporter.initialize()
    context = FastXlsxExporter.put_row(first_row, context)
    context = FastXlsxExporter.put_row(second_row, context)
    filename = XlsxReader.random_file_path()
    :ok = FastXlsxExporter.finalize_to_file(context, filename)

    rows = XlsxReader.read_file(filename)
    XlsxReader.delete_file(filename)

    assert 2 = Enum.count(rows)
    assert first_row == Enum.at(rows, 0)
    assert second_row == Enum.at(rows, 1)
  end

  test "writes numbers to document" do
    first_row = [1, 2, 3]
    second_row = [4, {5, :percents}, {nil, :percents}]

    context = FastXlsxExporter.initialize()
    context = FastXlsxExporter.put_row(first_row, context)
    context = FastXlsxExporter.put_row(second_row, context)
    {:ok, document} = FastXlsxExporter.finalize(context)

    rows = XlsxReader.read_document(document)
    assert 2 = Enum.count(rows)
    assert first_row == Enum.at(rows, 0)
    assert [4, 5] == Enum.at(rows, 1)
  end

  test "writes date and time to document" do
    row = [~D[1900-01-10], ~D[2020-04-09], ~N[2020-04-09 12:00:00]]

    context = FastXlsxExporter.initialize()
    context = FastXlsxExporter.put_row(row, context)
    {:ok, document} = FastXlsxExporter.finalize(context)

    rows = XlsxReader.read_document(document)
    assert 1 = Enum.count(rows)
    assert [{1900, 01, 10}, {2020, 4, 9}, ~N[2020-04-09 12:00:00]] == Enum.at(rows, 0)
  end

  test "writes dictionary strings" do
    first_row = [
      {"some_string", :dictionary},
      {"some_other_string", :dictionary},
      {"some_string", :dictionary},
      {nil, :dictionary}
    ]

    second_row = ["wow!", {"some_other_string", :dictionary}, "yay!"]

    context = FastXlsxExporter.initialize()
    context = FastXlsxExporter.put_row(first_row, context)
    context = FastXlsxExporter.put_row(second_row, context)
    {:ok, document} = FastXlsxExporter.finalize(context)

    rows = XlsxReader.read_document(document)
    assert 2 = Enum.count(rows)
    assert ["some_string", "some_other_string", "some_string"] == Enum.at(rows, 0)
    assert ["wow!", "some_other_string", "yay!"] == Enum.at(rows, 1)
  end
end
