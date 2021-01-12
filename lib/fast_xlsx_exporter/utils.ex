defmodule FastXlsxExporter.Utils do
  @moduledoc false

  @spec open_new_file(binary(), binary()) :: {:ok, :file.io_device()}
  def open_new_file(base_path, path) do
    sheet_path = Path.join(base_path, path)
    {:ok, fd} = :file.open(to_charlist(sheet_path), [:append])
    :file.truncate(fd)
    {:ok, fd}
  end
end
