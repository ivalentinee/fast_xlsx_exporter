defmodule FastXlsxExporter.Sheet.DateTimeFormatter do
  @initial_date ~D[1900-01-01]
  @initial_time ~T[00:00:00]
  @seconds_per_day 86400

  def format_datetime(%NaiveDateTime{} = value) do
    date = NaiveDateTime.to_date(value)
    date_chunk = Date.diff(date, @initial_date)
    time = Time.diff(NaiveDateTime.to_time(value), @initial_time)
    time_chunk = time / @seconds_per_day

    if lotus_leap_year_bug?(date_chunk) do
      2 + date_chunk + time_chunk
    else
      1 + date_chunk + time_chunk
    end
  end

  defp lotus_leap_year_bug?(date_chunk), do: date_chunk >= 59
end
