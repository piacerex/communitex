defmodule BasicWeb.AccountSettingsController do
  use BasicWeb, :controller

  alias Basic.Accounts
  alias BasicWeb.AccountAuth

  plug :assign_email_and_password_changesets

  def edit(conn, _params) do
    render(conn, "edit.html")
  end

  def update(conn, %{"action" => "update_email"} = params) do
    %{"current_password" => password, "account" => account_params} = params
    account = conn.assigns.current_account

    case Accounts.apply_account_email(account, password, account_params) do
      {:ok, applied_account} ->
        Accounts.deliver_update_email_instructions(
          applied_account,
          account.email,
          &Routes.account_settings_url(conn, :confirm_email, &1)
        )

        conn
        |> put_flash(
          :info,
#          "A link to confirm your email change has been sent to the new address."
          "メールアドレス変更を確認するためのリンクを新しいメールアドレスに送信しました"
        )
        |> redirect(to: Routes.account_settings_path(conn, :edit))

      {:error, changeset} ->
        render(conn, "edit.html", email_changeset: changeset)
    end
  end

  def update(conn, %{"action" => "update_password"} = params) do
    %{"current_password" => password, "account" => account_params} = params
    account = conn.assigns.current_account

    case Accounts.update_account_password(account, password, account_params) do
      {:ok, account} ->
        conn
#        |> put_flash(:info, "Password updated successfully.")
        |> put_flash(:info, "パスワードの更新に成功しました")
        |> put_session(:account_return_to, Routes.account_settings_path(conn, :edit))
        |> AccountAuth.log_in_account(account)

      {:error, changeset} ->
        render(conn, "edit.html", password_changeset: changeset)
    end
  end

  def confirm_email(conn, %{"token" => token}) do
    case Accounts.update_account_email(conn.assigns.current_account, token) do
      :ok ->
        conn
#        |> put_flash(:info, "Email changed successfully.")
        |> put_flash(:info, "メールアドレス変更に成功しました")
        |> redirect(to: Routes.account_settings_path(conn, :edit))

      :error ->
        conn
#        |> put_flash(:error, "Email change link is invalid or it has expired.")
        |> put_flash(:error, "このメールアドレス変更URLは正しくないか、期限切れとなっております")
        |> redirect(to: Routes.account_settings_path(conn, :edit))
    end
  end

  defp assign_email_and_password_changesets(conn, _opts) do
    account = conn.assigns.current_account

    conn
    |> assign(:email_changeset, Accounts.change_account_email(account))
    |> assign(:password_changeset, Accounts.change_account_password(account))
  end
end
