defmodule AsBackendTheme2Web.Router do
  use AsBackendTheme2Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", AsBackendTheme2Web do
    pipe_through :api


    resources "/users", UserController, except: [:new, :edit]


    get    "/workingtime/:userID",       WorkingTimeController, :index_by_user
    get    "/workingtime/:userID/:id",   WorkingTimeController, :show_one
    post   "/workingtime/:userID",       WorkingTimeController, :create_for_user
    put    "/workingtime/:id",           WorkingTimeController, :update
    delete "/workingtime/:id",           WorkingTimeController, :delete


    # CLOCK ROUTES
    get  "/clocks/:userID", ClockController, :index_by_user
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
