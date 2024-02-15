defmodule Beans.Repo do
  use Ecto.Repo,
    otp_app: :beans,
    adapter: Ecto.Adapters.Postgres
end
