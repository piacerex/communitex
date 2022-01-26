defmodule BasicWeb.AccountRegistrationController do
  use BasicWeb, :controller

  alias Basic.Accounts
  alias Basic.Accounts.Account
  alias BasicWeb.AccountAuth

  def new(conn, _params) do
    changeset = Accounts.change_account_registration(%Account{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"account" => account_params}) do
    case Accounts.register_account(account_params) do
      {:ok, account} ->
        {result, url} =
          Accounts.deliver_account_confirmation_instructions(
            account,
            &Routes.account_confirmation_url(conn, :edit, &1)
          )

        info_message = case result do
          :unsent -> url
          _ -> ""
        end

        conn
#        |> put_flash(:info, "Account created successfully.")
        |> put_flash(:info, info_message)
#        |> AccountAuth.log_in_account(account)
        |> render("done.html")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, error_message: nil)
    end
  end
end
