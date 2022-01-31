defmodule BasicWeb.AccountSessionController do
  use BasicWeb, :controller

  alias Basic.Accounts
  alias BasicWeb.AccountAuth

  def new(conn, _params) do
    render(conn, "new.html", error_message: nil)
  end

  def create(conn, %{"account" => account_params}) do
    %{"email" => email, "password" => password} = account_params

    if account = Accounts.get_account_by_email_and_password(email, password) do
      AccountAuth.log_in_account(conn, account, account_params)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
#      render(conn, "new.html", error_message: "Invalid email or password")
      render(conn, "new.html", error_message: "メールアドレスかパスワードが正しくありません")
    end
  end

  def delete(conn, _params) do
    conn
#    |> put_flash(:info, "Logged out successfully.")
    |> put_flash(:info, "ログアウトしました")
    |> AccountAuth.log_out_account()
  end
end
