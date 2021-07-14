defmodule Basic.Repo do
  use Ecto.Repo,
    otp_app: :basic,
    adapter: Ecto.Adapters.Postgres
end
