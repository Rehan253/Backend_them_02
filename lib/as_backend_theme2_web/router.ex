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

  scope "/api", AsBackendTheme2Web do
    pipe_through :api

    # ============================================================================
    # USER MANAGEMENT ROUTES
    # ============================================================================
    # Standard RESTful routes for user CRUD operations
    resources "/users", UserController, except: [:new, :edit]


    # ============================================================================
    # WORKING TIME ROUTES
    # ============================================================================
    # GET /api/workingtime/:userID?start=...&end=... - List working times for user (with optional date filtering)
    get "/workingtime/:userID", WorkingTimeController, :index_by_user

    # GET /api/workingtime/:userID/:id - Get specific working time entry for user
    get "/workingtime/:userID/:id", WorkingTimeController, :show_one

    # POST /api/workingtime/:userID - Create new working time entry for user
    post "/workingtime/:userID", WorkingTimeController, :create_for_user

    # PUT /api/workingtime/:id - Update existing working time entry
    put "/workingtime/:id", WorkingTimeController, :update

    # DELETE /api/workingtime/:id - Delete working time entry
    delete "/workingtime/:id", WorkingTimeController, :delete

    # ============================================================================
    # CLOCK IN/OUT ROUTES
    # ============================================================================
    # GET /api/clocks/:userID - Get all clock entries for user (most recent first)
    get "/clocks/:userID", ClockController, :index_by_user

    # POST /api/clocks/:userID - Toggle clock in/out status for user
    # This is the main endpoint for clock in/out functionality
    post "/clocks/:userID", ClockController, :toggle
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:as_backend_theme2, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: AsBackendTheme2Web.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
