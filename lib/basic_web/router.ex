defmodule BasicWeb.Router do
  use BasicWeb, :router

  import BasicWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {BasicWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  ## Authentication routes

  scope "/", BasicWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/users/register", UserRegistrationController, :new
    post "/users/register", UserRegistrationController, :create
    get "/users/log_in", UserSessionController, :new
    post "/users/log_in", UserSessionController, :create
    get "/users/reset_password", UserResetPasswordController, :new
    post "/users/reset_password", UserResetPasswordController, :create
    get "/users/reset_password/:token", UserResetPasswordController, :edit
    put "/users/reset_password/:token", UserResetPasswordController, :update
  end

  scope "/", BasicWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/users/settings", UserSettingsController, :edit
    put "/users/settings", UserSettingsController, :update
    get "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email
  end

  scope "/", BasicWeb do
    pipe_through [:browser]

#    delete "/users/log_out", UserSessionController, :delete
    get "/users/log_out", UserSessionController, :delete
    get "/users/confirm", UserConfirmationController, :new
    post "/users/confirm", UserConfirmationController, :create
    get "/users/confirm/:token", UserConfirmationController, :confirm
  end

  scope "/api/rest/", BasicWeb do
    pipe_through :api

    get "/*path_", RestApiController, :index
    post "/*path_", RestApiController, :create
    put "/*path_", RestApiController, :update
    delete "/*path_", RestApiController, :delete
  end

  scope "/api/", BasicWeb do
    pipe_through :api

    #TODO: Shotrize化する？
    get    "/file/list",        FileController, :list
    post   "/file/upload",      FileController, :upload
    put    "/file/new_file",    FileController, :new_file
    put    "/file/new_folder",  FileController, :new_folder
    delete "/file/remove",      FileController, :remove

    get "/*path_", ApiController, :index
    post "/*path_", ApiController, :index
    put "/*path_", ApiController, :index
    delete "/*path_", ApiController, :index
  end

  pipeline :sphere_browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, false
#    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  scope "/sphere/", BasicWeb do
#    pipe_through [:sphere_browser, :require_authenticated_user]
    pipe_through :sphere_browser

    get "/edit/*path_", SphereController, :edit
  end

  scope "/", BasicWeb do
    pipe_through :browser

    live "/members", MemberLive.Index, :index
    live "/members/new", MemberLive.Index, :new
    live "/members/:id/edit", MemberLive.Index, :edit

    live "/members/:id", MemberLive.Show, :show
    live "/members/:id/show/edit", MemberLive.Show, :edit

#    live "/", PageLive, :index
#    get "/*path_", PageController, :index
#    post "/*path_", PageController, :index
  end

  scope "/", BasicWeb do
    pipe_through :sphere_browser

    get "/*path_",  SphereController, :index
    post "/*path_", SphereController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", BasicWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: BasicWeb.Telemetry
    end
  end
end
