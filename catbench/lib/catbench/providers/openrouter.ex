defmodule Catbench.Providers.OpenRouter do
  @moduledoc """
  OpenRouter provider for the benchmark. This is the base provider, can be extended with others e.g. Anthropic, OpenAI, etc...
  """

  @endpoint "https://openrouter.ai/api/v1/chat/completions"

  def chat(model, system_prompt, prompt, temperature \\ 0, top_p \\ 1) do
    api_key = System.get_env("OPENROUTER_API_KEY") || raise "OPENROUTER_API_KEY must be set"

    headers = [
      {"Authorization", "Bearer #{api_key}"},
      {"Content-Type", "application/json"},
      # Define metrics for the OpenRouter benchmarks as well
      {"X-Title", "CATBench"}
    ]

    messages =
      [
        system_prompt && %{"role" => "system", "content" => system_prompt},
        %{"role" => "user", "content" => prompt}
      ]
      |> Enum.filter(& &1)

    body = %{
      "model" => model,
      "messages" => messages,
      "temperature" => temperature,
      "top_p" => top_p
    }

    t0 = System.monotonic_time(:millisecond)
    resp = Req.post!(@endpoint, headers: headers, json: body)
    t1 = System.monotonic_time(:millisecond)
    latency_ms = t1 - t0

    case resp.status do
      200 ->
        content = get_in(resp.body, ["choices", Access.at(0), "message", "content"]) || ""
        usage = Map.get(resp.body, "usage", %{})
        {:ok, %{content: content, usage: usage, latency_ms: latency_ms, model: model}}

      _ ->
        {:error, %{status: resp.status, body: resp.body}}
    end
  end
end
