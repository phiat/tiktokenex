defmodule Tiktokenex.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # Warm rank caches in a supervised Task so the ~13MB o200k parse
    # does not block app boot (releases with short startup timeouts
    # would otherwise risk spurious failures). Concurrent first-call
    # races are eliminated by the :global.trans guard in Ranks.load/1.
    children = [
      {Task, fn -> Tiktokenex.Ranks.warmup() end}
    ]

    opts = [strategy: :one_for_one, name: Tiktokenex.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
