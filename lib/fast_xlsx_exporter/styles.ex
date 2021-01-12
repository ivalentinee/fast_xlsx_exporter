defmodule FastXlsxExporter.Styles do
  @moduledoc false

  require EEx

  alias FastXlsxExporter.Utils

  @path Path.join(["xl", "styles.xml"])

  EEx.function_from_file(:defp, :render_styles, "#{__DIR__}/styles/styles.xml.eex", [])

  def write(base_path) do
    {:ok, fd} = Utils.open_new_file(base_path, @path)
    content = render_styles()
    :file.write(fd, content)
    :file.close(fd)
  end
end
