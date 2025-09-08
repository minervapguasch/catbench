defmodule Catbench.Prompt do
  @moduledoc """
  Prompt module for Catbench, all the logic for the prompts and conditions
  """

  @system_prompt_cloze "Ets un corrector de català. Respon només amb la paraula correcta."
  @system_prompt_mcq "Ets un avaluador de català. Respon només amb la lletra A, B, C o D que correspon a la opció correcta."

  def build(%{
        "task" => "cloze",
        "instruction" => instruction,
        "text" => text
      }) do
    system = @system_prompt_cloze

    prompt = """
      #{instruction}

      Frase:
      #{text}

      Recorda: respon només amb una sola paraula, sense explicacions.
    """

    {system, prompt}
  end

  def build(%{
        "task" => "mcq",
        "instruction" => instruction,
        "text" => text,
        "options" => options
      }) do
    system = @system_prompt_mcq
    letters = ["A", "B", "C", "D"]

    listed =
      letters
      |> Enum.zip(options)
      |> Enum.map(fn {l, opt} -> "#{l}. #{opt}" end)
      |> Enum.join("\n")

    prompt = """
      #{instruction}

      Frase:
      #{text}

      Opcions:
      #{listed}

      Recorda: respon només amb la lletra corresponent a la opció correcta.
    """

    {system, prompt}
  end
end
