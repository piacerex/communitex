defmodule BasicWeb.UserConfirmationController do
  use BasicWeb, :controller

  alias Basic.Accounts

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"user" => %{"email" => email}}) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_confirmation_instructions(
        user,
        &Routes.user_confirmation_url(conn, :confirm, &1)
      )
    end

    # Regardless of the outcome, show an impartial success/error message.
    conn
    |> put_flash(
      :info,
#      "If your email is in our system and it has not been confirmed yet, " <>
#        "you will receive an email with instructions shortly."
      "お使いのメールアドレスが登録済みで確認済みで無い場合、メールにて手順がまもなく届きます"
    )
    |> redirect(to: "/")
  end

  # Do not log in the user after confirmation to avoid a
  # leaked token giving the user access to the account.
  def confirm(conn, %{"token" => token}) do
    case Accounts.confirm_user(token) do
      {:ok, _} ->
        conn
#        |> put_flash(:info, "Account confirmed successfully.")
        |> put_flash(:info, "ユーザ登録確認に成功しました")
        |> redirect(to: "/")

      :error ->
        # If there is a current user and the account was already confirmed,
        # then odds are that the confirmation link was already visited, either
        # by some automation or by the user themselves, so we redirect without
        # a warning message.
        case conn.assigns do
          %{current_user: %{confirmed_at: confirmed_at}} when not is_nil(confirmed_at) ->
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
