defmodule Catbench.Scorer do
  @moduledoc """
  Scorer with utils for score the responses
  """

  @doc """
  Normalize the response
  """
  def normalize_response(string) when is_binary(string) do
    string
      |> String.trim()
      |> String.trim_trailing(".")
      |> String.downcase()
  end

  def score(%{
    "expect" => %{
      "type" => "exact",
      "value" => value
    }
  }, output) do
    ok = normalize_response(output) == normalize_response(value)
    {ok, %{"expected" => value}}
  end

  def score(%{
    "expect" => %{
      "type" => "regex",
      "pattern" => pattern
    }
  }, output) do
    {:ok, regex} = Regex.compile(pattern, "iu")
    ok = Regex.match?(regex, String.trim(output))
    {ok, %{"pattern" => pattern}}
  end

  def score(%{
    "task" => "mcq",
    "correct" => correct_letter
  }, output) do
    out = output
      |> String.trim()
      |> String.first()
      |> String.upcase()

    {out == String.upcase(correct_letter), %{"correct" => correct_letter}}
  end

  def score(_item, _output), do: {false, %{"error" => "no_scorer_for_this_task"}}
end
