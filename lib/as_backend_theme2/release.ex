defmodule AsBackendTheme2.Release do
  @moduledoc false

  def seed do
    # Start only needed apps (no web endpoint)
    IO.puts("Starting apps for seeding...")
    {:ok, _} = Application.ensure_all_started(:ssl)
    {:ok, _} = Application.ensure_all_started(:crypto)
    {:ok, _} = Application.ensure_all_started(:postgrex)
    {:ok, _} = Application.ensure_all_started(:ecto)
    {:ok, _} = Application.ensure_all_started(:ecto_sql)

    # Start your Repo manually
    IO.puts("Starting Ecto Repo manually...")
    AsBackendTheme2.Repo.start_link()

    # Now run the seed script
    seed_file = Application.app_dir(:as_backend_theme2, "priv/repo/seeds.exs")

    IO.puts("Running seed script at: #{seed_file}")
    Code.eval_file(seed_file)

    IO.puts("Seeding complete!")
  end
end
