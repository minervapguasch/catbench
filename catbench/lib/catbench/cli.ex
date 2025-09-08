defmodule Catbench.CLI do
  @moduledoc """
  CLI module for Catbench
  """
  alias Catbench.IO, as: BenchmarkIO
  alias Catbench.Runner

  @default_models_to_benchmark [
    "openai/gpt-4o-mini",
    "anthropic/claude-3.5-haiku",
    "google/gemini-2.5-flash",
    "x-ai/grok-3-mini",
    "qwen/qwq-32b",
    "mistralai/mistral-medium-3.1",
    "nousresearch/hermes-4-70b"
  ]

  @doc """
  Main function for the CLI
  """
  def main(args) do
    IO.puts("--- Començant CATBench...")
    start_time = DateTime.utc_now()
    {opts, _, _} =
      OptionParser.parse(args,
        strict: [models: :string, input: :string, out: :string, concurrency: :integer],
        aliases: [m: :models, i: :input, o: :out, c: :concurrency]
      )

    models = @default_models_to_benchmark
      case opts[:models] do
        nil -> @default_models_to_benchmark
        models_str -> String.split(models_str, ",", trim: true)
      end

    IO.puts(" |- Models que s'analitzaran: #{models |> Enum.join(", ")}")

    input = opts[:input] || "data/ca_items.yaml"
    out = opts[:out] || "results.json"
    concurrency = opts[:concurrency] || 8

    items = BenchmarkIO.load_items(input)
    data = Runner.run(items, models, concurrency: concurrency)

    report = %{
      "generated_at" => DateTime.utc_now() |> DateTime.to_iso8601(),
      "models" => data
    }

    BenchmarkIO.write_results(report, out)
    IO.puts(" |- Resultats escrits a #{out}")
    IO.puts("--- CATBench finalitzat. Temps total: #{DateTime.diff(DateTime.utc_now(), start_time)} segons")
  end
end
