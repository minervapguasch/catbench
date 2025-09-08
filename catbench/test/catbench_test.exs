defmodule CatbenchTest do
  use ExUnit.Case

  test "OpenRouter returns content, usage and latency" do
    assert {:ok, resp} =
             Catbench.Providers.OpenRouter.chat(
               "gpt-4o-mini",
               "You are a helpful assistant.",
               "Hello, how are you?",
               0,
               1
             )

    assert is_map(resp)
    assert is_binary(resp.content)
    assert is_integer(resp.latency_ms) and resp.latency_ms >= 0
    assert is_map(resp.usage)
    assert Map.has_key?(resp.usage, "prompt_tokens")
    assert Map.has_key?(resp.usage, "completion_tokens")
  end
end
