defmodule FastXlsxExporter.Sheet.Cell do
  @moduledoc false

  require EEx

  alias FastXlsxExporter.Sheet.DateTimeFormatter

  def render(id, {value, :percents}) when is_number(value), do: render_percent(id, value)
  def render(id, {value, _}) when is_number(value), do: render_number(id, value)
  def render(id, {value, _}) when is_binary(value), do: render_string(id, value)

  def render(id, {%Date{} = value, _}),
    do: render_date(id, DateTimeFormatter.format_date(value))

  def render(id, {%NaiveDateTime{} = value, _}),
    do: render_datetime(id, DateTimeFormatter.format_datetime(value))

  EEx.function_from_file(:defp, :render_number, "#{__DIR__}/cells/number.xml.eex", [:id, :value])

  EEx.function_from_file(:defp, :render_percent, "#{__DIR__}/cells/percent.xml.eex", [:id, :value])

  EEx.function_from_file(:defp, :render_string, "#{__DIR__}/cells/string.xml.eex", [:id, :value])

  EEx.function_from_file(:defp, :render_date, "#{__DIR__}/cells/date.xml.eex", [
    :id,
    :value
  ])

  EEx.function_from_file(:defp, :render_datetime, "#{__DIR__}/cells/datetime.xml.eex", [
    :id,
    :value
  ])
end
