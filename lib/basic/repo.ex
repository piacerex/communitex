defmodule Basic.Repo do
  use Ecto.Repo,
    otp_app: :basic,
    adapter: Ecto.Adapters.Postgres

  use Scrivener, page_size: 2
end
