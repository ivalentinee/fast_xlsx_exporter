defmodule FastXlsxExporter.Sample do
  require EEx

  @template_prefix "#{__DIR__}/sample/"
  @template_suffix ".eex"

  @files [
    render_content_types: "[Content_Types].xml",
    render_rels: "_rels/.rels",
    render_props_app: "docProps/app.xml",
    render_props_core: "docProps/core.xml",
    render_workbook_rels: "xl/_rels/workbook.xml.rels",
    render_workbook: "xl/workbook.xml",
    render_sheet: "xl/worksheets/sheet1.xml"
  ]

  Enum.each(@files, fn {id, path} ->
    template_path = @template_prefix <> path <> @template_suffix
    template_expression = EEx.compile_file(template_path)

    def write_file(base_path, unquote(id)) do
      full_path = Path.join(base_path, unquote(path))
      File.write(full_path, unquote(template_expression))
    end
  end)

  def write(base_path) do
    make_dirs(base_path)
    write_files(base_path)
  end

  defp make_dirs(base_path) do
    @files
    |> Enum.map(fn {_id, filename} -> Path.dirname(filename) end)
    |> Enum.uniq()
    |> Enum.each(fn dir_path ->
      full_dir_path = Path.join(base_path, dir_path)
      File.mkdir_p!(full_dir_path)
    end)
  end

  defp write_files(base_path) do
    Enum.each(@files, fn {id, _} -> write_file(base_path, id) end)
  end
end
