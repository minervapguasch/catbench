defmodule Catbench.IO do
  @moduledoc """
  IO module for reading and writing results to files
  """

  def load_items(path) do
    case Path.extname(path) do
      ".yaml" -> load_yaml(path)
      ".yml" -> load_yaml(path)
      _ -> raise "Unsupported input file extension (use YAML)"
    end
  end

  defp load_yaml(path) do
    %{
      "items" => items
    } = YamlElixir.read_from_file!(path)

    Enum.map(items, &stringify_keys/1)
  end

  def write_results(data, output_json_path) do
    json = Jason.encode_to_iodata!(data)
    File.write!(output_json_path, json)
    :ok
  end

  defp stringify_keys(map) when is_map(map) do
    for {k, v} <- map, into: %{}, do: {to_string(k), stringify(v)}
  end

  defp stringify(v) when is_map(v), do: stringify_keys(v)
  defp stringify(v) when is_list(v), do: Enum.map(v, &stringify/1)
  defp stringify(v) when is_binary(v), do: v
  defp stringify(v), do: v
end
