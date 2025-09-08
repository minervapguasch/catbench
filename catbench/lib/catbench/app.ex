defmodule Catbench.App do
  @moduledoc """
  Application module for Catbench, entrypoint
  """
  use Application

  def start(_type, _args) do
    children = [
      {Finch, name: Catbench.Finch}
    ]
    Supervisor.start_link(children, strategy: :one_for_one, name: Catbench.Supervisor)
  end
end
