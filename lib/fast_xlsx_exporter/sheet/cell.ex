defmodule FastXlsxExporter.Sheet.Cell do
  require EEx

  @seconds_per_day 86400

  def render(id, {value, :percents}) when is_number(value), do: render_percent(id, value)
  def render(id, {value, _}) when is_number(value), do: render_number(id, value)
  def render(id, {value, _}) when is_binary(value), do: render_string(id, value)
  def render(id, {%NaiveDateTime{} = value, _}), do: render_datetime(id, format_datetime(value))

  EEx.function_from_file(:defp, :render_number, "#{__DIR__}/cells/number.xml.eex", [:id, :value])
  EEx.function_from_file(:defp, :render_percent, "#{__DIR__}/cells/percent.xml.eex", [:id, :value])
  EEx.function_from_file(:defp, :render_string, "#{__DIR__}/cells/string.xml.eex", [:id, :value])
  EEx.function_from_file(:defp, :render_datetime, "#{__DIR__}/cells/datetime.xml.eex", [:id, :value])

  defp format_datetime(%NaiveDateTime{} = value) do
    date = NaiveDateTime.to_date(value)
    date_chunk = Date.diff(date, ~D[1899-12-30])
    time = Time.diff(~T[00:00:00], NaiveDateTime.to_time(value))
    time_chunk = time / @seconds_per_day

    date_chunk + time_chunk
  end
end
