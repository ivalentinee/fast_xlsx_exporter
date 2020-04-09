# NOTE: Have to rely on xlsxir for tests
defmodule FastXlsxExporterTest do
  use ExUnit.Case

  alias FastXlsxExporter.XlsxReader

  test "writes head to document" do
    head = ["column1", "column2", "column3"]

    {:ok, {_filename, document}} =
      FastXlsxExporter.initialize(0, head)
      |> FastXlsxExporter.finalize()

    rows = XlsxReader.read_document(document)
    assert 1 = Enum.count(rows)
    assert head == Enum.at(rows, 0)
  end

  test "writes strings to document" do
    head = ["column1", "column2", "column3"]
    first_row = ["value 1", "value 2", "value 3"]
    second_row = ["value 4", "value 5"]

    context = FastXlsxExporter.initialize(2, head)
    context = FastXlsxExporter.put_row(first_row, context)
    context = FastXlsxExporter.put_row(second_row, context)
    {:ok, {_filename, document}} = FastXlsxExporter.finalize(context)

    rows = XlsxReader.read_document(document)
    assert 3 = Enum.count(rows)
    assert first_row == Enum.at(rows, 1)
    assert second_row == Enum.at(rows, 2)
  end

  test "writes numbers to document" do
    head = ["column1", "column2", "column3"]
    first_row = [1, 2, 3]
    second_row = [4, {5, :percents}]

    context = FastXlsxExporter.initialize(2, head)
    context = FastXlsxExporter.put_row(first_row, context)
    context = FastXlsxExporter.put_row(second_row, context)
    {:ok, {_filename, document}} = FastXlsxExporter.finalize(context)

    rows = XlsxReader.read_document(document)
    assert 3 = Enum.count(rows)
    assert first_row == Enum.at(rows, 1)
    assert [4, 5] == Enum.at(rows, 2)
  end

  test "writes date and time to document" do
    head = ["column1", "column2", "column3"]
    row = [~D[1905-12-11], ~D[2020-04-09], ~N[2020-04-09 12:00:00]]

    context = FastXlsxExporter.initialize(2, head)
    context = FastXlsxExporter.put_row(row, context)
    {:ok, {_filename, document}} = FastXlsxExporter.finalize(context)

    rows = XlsxReader.read_document(document)
    assert 2 = Enum.count(rows)
    assert [{1905, 12, 11}, {2020, 4, 9}, ~N[2020-04-09 12:00:00]] == Enum.at(rows, 1)
  end
end
