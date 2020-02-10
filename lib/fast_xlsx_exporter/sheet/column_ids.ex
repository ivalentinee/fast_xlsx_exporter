defmodule FastXlsxExporter.Sheet.ColumnIds do
  @moduledoc false

  @letters [
    "A",
    "B",
    "C",
    "D",
    "E",
    "F",
    "G",
    "H",
    "I",
    "J",
    "K",
    "L",
    "M",
    "N",
    "O",
    "P",
    "Q",
    "R",
    "S",
    "T",
    "U",
    "V",
    "W",
    "X",
    "Y",
    "Z"
  ]

  @double_letters Enum.reduce(@letters, [], fn letter, columns ->
                    columns ++ Enum.map(@letters, &"#{letter}#{&1}")
                  end)

  @triple_letters Enum.reduce(@double_letters, [], fn letter, columns ->
                    columns ++ Enum.map(@letters, &"#{letter}#{&1}")
                  end)

  @column_ids @letters ++ @double_letters ++ @triple_letters

  def column_ids, do: @column_ids
end
