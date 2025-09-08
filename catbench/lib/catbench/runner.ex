defmodule Catbench.Runner do
  @moduledoc """
  Runner for the CATBench
  """
  alias Catbench.Prompt
  alias Catbench.Scorer
  alias Catbench.Providers.OpenRouter

  @concurrency 6
  @timeout 20_000
  @default_pricing_per_million %{
    "openai/gpt-4o-mini" => %{input: 0.15, output: 0.60},
    "anthropic/claude-3.5-haiku" => %{input: 0.80, output: 4.00},
    "google/gemini-2.5-flash" => %{input: 0.30, output: 2.50},
    "x-ai/grok-3-mini" => %{input: 0.30, output: 0.50},
    "qwen/qwq-32b" => %{input: 0.075, output: 0.15},
    "mistralai/mistral-medium-3.1" => %{input: 0.40, output: 2.00},
    "nousresearch/hermes-4-70b" => %{input: 0.093, output: 0.373}
  }

  def run(items, models, opts \\ []) do
    concurrency = opts[:concurrency] || @concurrency
    timeout = opts[:timeout] || @timeout
    pricing_map = opts[:pricing] || @default_pricing_per_million

    Enum.map(models, fn model ->
      results =
        items
        |> Task.async_stream(
          fn item -> run_item_prompt(model, item, pricing_map) end,
          max_concurrency: concurrency,
          timeout: timeout,
          on_timeout: :kill_task
        )
        |> Enum.map(fn
          {:ok, res} -> res
          {:exit, _} -> %{"error" => "timeout_or_crash_error"}
        end)

      summary = summarize_results(results)

      %{
        model: model,
        summary: summary,
        results: results
      }
    end)
  end

  defp run_item_prompt(model, item, pricing_map) do
    {system, prompt} = Prompt.build(item)

    with {:ok, %{content: output, usage: usage, latency_ms: latency_ms}} <-
           OpenRouter.chat(model, system, prompt) do
      {is_ok, meta} = Scorer.score(item, output)

      tokens = %{
        prompt: Map.get(usage, "prompt_tokens", 0),
        completion: Map.get(usage, "completion_tokens", 0),
        total:
          Map.get(
            usage,
            "total_tokens",
            Map.get(usage, "prompt_tokens", 0) + Map.get(usage, "completion_tokens", 0)
          )
      }

      price = compute_request_price(tokens, model, pricing_map)

      %{
        id: item["id"],
        ok: is_ok,
        output: String.trim(output),
        meta: meta,
        tokens: tokens,
        latency_ms: latency_ms,
        price: price
      }
    end
  end

  defp compute_request_price(tokens, model, pricing_map) do
    pricing = Map.get(pricing_map, model, %{})
    input_ppm = Map.get(pricing, :input, Map.get(pricing, "input", 0.0))
    output_ppm = Map.get(pricing, :output, Map.get(pricing, "output", 0.0))

    prompt_tokens = Map.get(tokens, :prompt, Map.get(tokens, "prompt", 0))
    completion_tokens = Map.get(tokens, :completion, Map.get(tokens, "completion", 0))

    price = (prompt_tokens * input_ppm + completion_tokens * output_ppm) / 1_000_000
    Float.round(price, 8)
  end

  defp accuracy_percentage(total, corrects) when total > 0 do
    Float.round(corrects / total * 100, 2)
  end

  defp summarize_results(results) do
    total = length(results)

    corrects =
      Enum.count(results, fn
        %{ok: true} -> true
        _ -> false
      end)

    {sum_prompt, sum_completion, sum_total, sum_latency, latency_count} =
      Enum.reduce(results, {0, 0, 0, 0, 0}, fn r, {sp, sc, st, sl, lc} ->
        tokens = Map.get(r, :tokens, %{})
        p = Map.get(tokens, :prompt, Map.get(tokens, "prompt", 0))
        c = Map.get(tokens, :completion, Map.get(tokens, "completion", 0))
        t = Map.get(tokens, :total, Map.get(tokens, "total", 0))
        latency = Map.get(r, :latency_ms, Map.get(r, "latency_ms", nil))

        sl2 = if is_integer(latency), do: sl + latency, else: sl
        lc2 = if is_integer(latency), do: lc + 1, else: lc

        {sp + p, sc + c, st + t, sl2, lc2}
      end)

    avg_latency_ms =
      if latency_count > 0 do
        Float.round(sum_latency / latency_count, 2)
      else
        0.0
      end

    %{
      total: total,
      corrects: corrects,
      accuracy_percentage: accuracy_percentage(total, corrects) || 0.0,
      tokens: %{
        prompt: sum_prompt,
        completion: sum_completion,
        total: sum_total
      },
      avg_latency_ms: avg_latency_ms
    }
  end
end
