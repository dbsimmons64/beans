defmodule BeansWeb.Router do
  use BeansWeb, :router

  import BeansWeb.UserAuth

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {BeansWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(:fetch_current_user)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", BeansWeb do
    pipe_through(:browser)

    get("/", PageController, :home)
  end

  # Other scopes may use custom stacks.
  # scope "/api", BeansWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:beans, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through(:browser)

      live_dashboard("/dashboard", metrics: BeansWeb.Telemetry)
      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end

  ## Authentication routes

  scope "/", BeansWeb do
    pipe_through([:browser, :redirect_if_user_is_authenticated])

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{BeansWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live("/users/register", UserRegistrationLive, :new)
      live("/users/log_in", UserLoginLive, :new)
      live("/users/reset_password", UserForgotPasswordLive, :new)
      live("/users/reset_password/:token", UserResetPasswordLive, :edit)
    end

    post("/users/log_in", UserSessionController, :create)
  end

  scope "/", BeansWeb do
    pipe_through([:browser, :require_authenticated_user])

    live_session :require_authenticated_user,
      on_mount: [{BeansWeb.UserAuth, :ensure_authenticated}] do
      live("/users/settings", UserSettingsLive, :edit)
      live("/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email)

      live("/accounts", AccountLive.Index, :index)
      live("/accounts/new", AccountLive.Index, :new)
      live("/accounts/:id/edit", AccountLive.Index, :edit)

      live("/accounts/:id", AccountLive.Show, :show)
      live("/accounts/:id/show/edit", AccountLive.Show, :edit)

      live("/accounts/:account_id/transactions", TransactionLive.Index, :index)
      live("/accounts/:account_id/transactions/new", TransactionLive.Index, :new)
      live("/accounts/:account_id/transactions/:id/edit", TransactionLive.Index, :edit)

      live("/accounts/:account_id/transactions/:id", TransactionLive.Show, :show)
      live("/accounts/:account_id/transactions/:id/show/edit", TransactionLive.Show, :edit)

      live("/splits", SplitLive.Index, :index)
      live("/splits/new", SplitLive.Index, :new)
      live("/splits/:id/edit", SplitLive.Index, :edit)

      live("/splits/:id", SplitLive.Show, :show)
      live("/splits/:id/show/edit", SplitLive.Show, :edit)

      live("/categories", CategoryLive.Index, :index)
      live("/categories/new", CategoryLive.Index, :new)
      live("/categories/:id/edit", CategoryLive.Index, :edit)

      live("/categories/:id", CategoryLive.Show, :show)
      live("/categories/:id/show/edit", CategoryLive.Show, :edit)
    end
  end

  scope "/", BeansWeb do
    pipe_through([:browser])

    delete("/users/log_out", UserSessionController, :delete)

    live_session :current_user,
      on_mount: [{BeansWeb.UserAuth, :mount_current_user}] do
      live("/users/confirm/:token", UserConfirmationLive, :edit)
      live("/users/confirm", UserConfirmationInstructionsLive, :new)
    end
  end
end
