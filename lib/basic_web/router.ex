defmodule BasicWeb.Router do
  use BasicWeb, :router

  import BasicWeb.AccountAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {BasicWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_account
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  ## Authentication routes

  scope "/", BasicWeb do
    pipe_through [:browser, :redirect_if_account_is_authenticated]

    get "/accounts/register", AccountRegistrationController, :new
    post "/accounts/register", AccountRegistrationController, :create
    get "/accounts/log_in", AccountSessionController, :new
    post "/accounts/log_in", AccountSessionController, :create
    get "/accounts/reset_password", AccountResetPasswordController, :new
    post "/accounts/reset_password", AccountResetPasswordController, :create
    get "/accounts/reset_password/:token", AccountResetPasswordController, :edit
    put "/accounts/reset_password/:token", AccountResetPasswordController, :update
  end

  scope "/", BasicWeb do
    pipe_through [:browser, :require_authenticated_account]

    get "/accounts/settings", AccountSettingsController, :edit
    put "/accounts/settings", AccountSettingsController, :update
    get "/accounts/settings/confirm_email/:token", AccountSettingsController, :confirm_email
  end

  scope "/", BasicWeb do
    pipe_through [:browser]

#    delete "/accounts/log_out", AccountSessionController, :delete
    get "/accounts/log_out", AccountSessionController, :delete
    get "/accounts/confirm", AccountConfirmationController, :new
    post "/accounts/confirm", AccountConfirmationController, :create
    get "/accounts/confirm/:token", AccountConfirmationController, :edit
    post "/accounts/confirm/:token", AccountConfirmationController, :update
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
# ユーザ登録時にエラーが出るのでコメントアウト
#      forward "/sent_emails", Bamboo.SentEmailViewerPlug
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  pipeline :sphere_browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, false
#    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_account
  end

  import BasicWeb.Grant
  scope "/sphere/", BasicWeb do
    pipe_through [:sphere_browser, :require_authenticated_account, :content_editor_grant]
#    pipe_through :sphere_browser

    get "/edit/*path_", SphereController, :edit
  end

  scope "/admin", BasicWeb do
    pipe_through [:browser, :require_authenticated_account, :distributor_admin_grant]

    live "/items", ItemLive.Index, :index
    live "/items/new", ItemLive.Index, :new
    live "/items/:id/edit", ItemLive.Index, :edit
    live "/items/:id", ItemLive.Show, :show
    live "/items/:id/show/edit", ItemLive.Show, :edit

    live "/distributors", DistributorLive.Index, :index
    live "/distributors/new", DistributorLive.Index, :new
    live "/distributors/:id/edit", DistributorLive.Index, :edit
    live "/distributors/:id", DistributorLive.Show, :show
    live "/distributors/:id/show/edit", DistributorLive.Show, :edit
  end

  scope "/admin", BasicWeb do
    pipe_through [:browser, :require_authenticated_account, :agency_admin_grant]

    live "/agents", AgentLive.Index, :index
    live "/agents/new", AgentLive.Index, :new
    live "/agents/:id/edit", AgentLive.Index, :edit
    live "/agents/:id", AgentLive.Show, :show
    live "/agents/:id/show/edit", AgentLive.Show, :edit

    live "/orders", OrderLive.Index, :index
    live "/orders/new", OrderLive.Index, :new
    live "/orders/:id/edit", OrderLive.Index, :edit
    live "/orders/:id", OrderLive.Show, :show
    live "/orders/:id/show/edit", OrderLive.Show, :edit

    live "/agencies", AgencyLive.Index, :index
    live "/agencies/new", AgencyLive.Index, :new
    live "/agencies/:id/edit", AgencyLive.Index, :edit
    live "/agencies/:id", AgencyLive.Show, :show
    live "/agencies/:id/show/edit", AgencyLive.Show, :edit

    live "/carts", CartLive.Index, :index
    live "/carts/new", CartLive.Index, :new
    live "/carts/:id/edit", CartLive.Index, :edit
    live "/carts/:id", CartLive.Show, :show
    live "/carts/:id/show/edit", CartLive.Show, :edit

    live "/addresses", AddressLive.Index, :index
    live "/addresses/new", AddressLive.Index, :new
    live "/addresses/:id/edit", AddressLive.Index, :edit
    live "/addresses/:id", AddressLive.Show, :show
    live "/addresses/:id/show/edit", AddressLive.Show, :edit

    live "/deliveries", DeliveryLive.Index, :index
    live "/deliveries/new", DeliveryLive.Index, :new
    live "/deliveries/:id/edit", DeliveryLive.Index, :edit
    live "/deliveries/:id", DeliveryLive.Show, :show
    live "/deliveries/:id/show/edit", DeliveryLive.Show, :edit
  end

  scope "/admin", BasicWeb do
    pipe_through [:browser, :require_authenticated_account, :organization_admin_grant]

    live "/members", MemberLive.Index, :index
    live "/members/new", MemberLive.Index, :new
    live "/members/:id/edit", MemberLive.Index, :edit
    live "/members/:id", MemberLive.Show, :show
    live "/members/:id/show/edit", MemberLive.Show, :edit

    live "/accounts", AccountLive.Index, :index
    live "/accounts/new", AccountLive.Index, :new
    live "/accounts/:id/edit", AccountLive.Index, :edit
    live "/accounts/:id", AccountLive.Show, :show
    live "/accounts/:id/show/edit", AccountLive.Show, :edit

    live "/organizations", OrganizationLive.Index, :index
    live "/organizations/new", OrganizationLive.Index, :new
    live "/organizations/:id/edit", OrganizationLive.Index, :edit
    live "/organizations/:id", OrganizationLive.Show, :show
    live "/organizations/:id/show/edit", OrganizationLive.Show, :edit
  end

  scope "/admin", BasicWeb do
    pipe_through [:browser, :require_authenticated_account, :any_admin_grant]

    live "/grants", GrantLive.Index, :index
    live "/grants/new", GrantLive.Index, :new

    live "/contacts", ContactLive.Index, :index
    live "/contacts/new", ContactLive.Index, :new
    live "/contacts/:id/edit", ContactLive.Index, :edit
    live "/contacts/:id", ContactLive.Show, :show
    live "/contacts/:id/show/edit", ContactLive.Show, :edit
  end

  scope "/admin", BasicWeb do
    pipe_through [:browser, :require_authenticated_account]

    live "/", AdminLive.Index, :index

    live "/blogs", BlogLive.Index, :index
    live "/blogs/new", BlogLive.Index, :new
    live "/blogs/:id/edit", BlogLive.Index, :edit
    live "/blogs/:id", BlogLive.Show, :show
    live "/blogs/:id/show/edit", BlogLive.Show, :edit
  end

  scope "/admin", BasicWeb do
    pipe_through [:browser, :require_authenticated_account, :system_admin_grant]

    live "/*path_", LiveViewController
  end

  scope "/", BasicWeb do
    pipe_through [:browser, :require_authenticated_account]

    live "/blogs/new", BlogUiLive.Index, :new
    live "/blogs/:post_id/edit", BlogUiLive.Index, :edit
    live "/blogs/:post_id/show/edit", BlogUiLive.Show, :edit
  end

  scope "/", BasicWeb do
    pipe_through :browser

    live "/members", MemberUiLive.Index, :index
    live "/members/:id", MemberUiLive.Show, :show

    live "/blogs", BlogUiLive.Index, :index
    live "/blogs/:post_id", BlogUiLive.Show, :show

    live "/items", ItemUiLive.Index, :index
    live "/items/:id", ItemUiLive.Show, :show

    live "/carts", CartUiLive.Index, :index
    live "/carts/register", CartUiLive.Register, :register
    live "/carts/:id/edit", CartUiLive.Index, :edit
    live "/carts/:id", CartUiLive.Show, :show
    live "/carts/:id/show/edit", CartUiLive.Show, :edit

    live "/addresses", AddressUiLive.Index, :index

    live "/*path_", SphereLive, :index

#    live "/", PageLive, :index
#    get "/*path_", PageController, :index
#    post "/*path_", PageController, :index
  end

  scope "/", BasicWeb do
    pipe_through :browser

#    get "/*path_",  SphereController, :index
#    post "/*path_", SphereController, :index
  end

end
