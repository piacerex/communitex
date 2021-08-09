defmodule BasicWeb.UserRegistrationController do
  use BasicWeb, :controller

  alias Basic.Accounts
  alias Basic.Accounts.User
  alias BasicWeb.UserAuth

  def new(conn, _params) do
    changeset = Accounts.change_user_registration(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {result, url} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &Routes.user_confirmation_url(conn, :confirm, &1)
          )

        info_message = case result do
          :unsent -> url
          _ -> ""
        end

        conn
#        |> put_flash(:info, "User created successfully.")
        |> put_flash(:info, info_message)
#        |> UserAuth.log_in_user(user)
        |> render("done.html")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, error_message: nil)
    end
  end
end
