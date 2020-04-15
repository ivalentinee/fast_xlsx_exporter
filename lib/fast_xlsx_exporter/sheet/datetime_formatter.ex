defmodule FastXlsxExporter.Sheet.DateTimeFormatter do
  @moduledoc false

  @initial_date ~D[1900-01-01]
  @initial_time ~T[00:00:00]
  @seconds_per_day 86_400

  def format_date(%Date{} = value) do
    date_chunk = Date.diff(value, @initial_date)

    2 + date_chunk
  end

  def format_datetime(%NaiveDateTime{} = value) do
    date = NaiveDateTime.to_date(value)
    time = Time.diff(NaiveDateTime.to_time(value), @initial_time)
    time_chunk = time / @seconds_per_day

    format_date(date) + time_chunk
  end
end
