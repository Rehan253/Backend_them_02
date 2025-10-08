defmodule AsBackendTheme2Web.Router do
  @moduledoc """
  Router for the Time Manager API.

  This router defines all the REST API endpoints for:
  - User management (CRUD operations)
  - Working time tracking (manual entries, filtering by date)
  - Clock in/out functionality (toggle status, retrieve history)

  All API routes are prefixed with /api and return JSON responses.
  """

  use AsBackendTheme2Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :api_auth do
    plug AsBackendTheme2Web.Plugs.AuthPlug
  end

  # =====================
  # Public API Routes
  # =====================
  scope "/api", AsBackendTheme2Web do
    pipe_through :api

    # User Registration & Login
    resources "/users", UserController, except: [:new, :edit]
    resources "/teams", TeamController, include: [:create]
    post "/login", SessionController, :login

    # GET only routes are open (no CSRF needed)
    get "/workingtime/:userID", WorkingTimeController, :index_by_user
    get "/workingtime/:userID/:id", WorkingTimeController, :show_one
    get "/clocks/:userID", ClockController, :index_by_user
  end

  # =====================
  # Protected Routes (JWT + CSRF required)
  # =====================
  scope "/api", AsBackendTheme2Web do
    pipe_through [:api, :api_auth]

    post "/users/change-password", UserController, :change_password
    put "/users/:id/change_role", UserController, :change_role
    post "/workingtime/:userID", WorkingTimeController, :create_for_user
    put "/workingtime/:id", WorkingTimeController, :update
    delete "/workingtime/:id", WorkingTimeController, :delete
    post "/teams/:team_id/users/:user_id", TeamController, :add_user
    delete "/teams/:team_id/users/:user_id", TeamController, :remove_user



    post "/clocks/:userID", ClockController, :toggle
  end

  # Dev tools (LiveDashboard, Mailbox)
  if Application.compile_env(:as_backend_theme2, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: AsBackendTheme2Web.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
