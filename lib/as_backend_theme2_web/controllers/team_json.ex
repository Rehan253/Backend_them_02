defmodule AsBackendTheme2Web.TeamJSON do
  alias AsBackendTheme2.Team

  @doc """
  Renders a list of teams.
  """
  def index(%{teams: teams}) do
    %{data: for(team <- teams, do: data(team))}
  end

  @doc """
  Renders a single team.
  """
  def show(%{team: team}) do
    %{data: data(team)}
  end

  defp data(%Team{} = team) do
    %{
      id: team.id,
      name: team.name,
      manager_id: team.manager_id,
      manager:
        team.manager &&
          %{
            id: team.manager.id,
            first_name: team.manager.first_name,
            last_name: team.manager.last_name,
            email: team.manager.email,
            role: team.manager.role && team.manager.role.name
          },
      users:
        team.users &&
          Enum.map(team.users, fn user ->
            %{
              id: user.id,
              first_name: user.first_name,
              last_name: user.last_name,
              email: user.email,
              role: user.role && user.role.name
            }
          end)
    }
  end
end
