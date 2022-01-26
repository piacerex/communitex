defmodule BasicWeb.AccountConfirmationController do
  use BasicWeb, :controller

  alias Basic.Accounts

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"account" => %{"email" => email}}) do
    if account = Accounts.get_account_by_email(email) do
      Accounts.deliver_account_confirmation_instructions(
        account,
        &Routes.account_confirmation_url(conn, :edit, &1)
      )
    end

    conn
    |> put_flash(
      :info,
#      "If your email is in our system and it has not been confirmed yet, " <>
#        "you will receive an email with instructions shortly."
      "お使いのメールアドレスが登録済みで確認済みで無い場合、メールにて手順がまもなく届きます"
    )
    |> redirect(to: "/")
  end

  def edit(conn, %{"token" => token}) do
    render(conn, "edit.html", token: token)
  end

  # Do not log in the account after confirmation to avoid a
  # leaked token giving the account access to the account.
  def update(conn, %{"token" => token}) do
    case Accounts.confirm_account(token) do
      {:ok, _} ->
        conn
#        |> put_flash(:info, "Account confirmed successfully.")
        |> put_flash(:info, "ユーザ登録確認に成功しました")
        |> redirect(to: "/")

      :error ->
        # If there is a current account and the account was already confirmed,
        # then odds are that the confirmation link was already visited, either
        # by some automation or by the account themselves, so we redirect without
        # a warning message.
        case conn.assigns do
          %{current_account: %{confirmed_at: confirmed_at}} when not is_nil(confirmed_at) ->
            redirect(conn, to: "/")

          %{} ->
            conn
#            |> put_flash(:error, "Account confirmation link is invalid or it has expired.")
            |> put_flash(:error, "ユーザ登録確認URLが正しくないか、期限切れとなっております")
            |> redirect(to: "/")
        end
    end
  end
end
