defmodule BasicWeb.AccountResetPasswordControllerTest do
  use BasicWeb.ConnCase, async: true

  alias Basic.Accounts
  alias Basic.Repo
  import Basic.AccountsFixtures

  setup do
    %{account: account_fixture()}
  end

  describe "GET /accounts/reset_password" do
    test "renders the reset password page", %{conn: conn} do
      conn = get(conn, Routes.account_reset_password_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "<h1>Forgot your password?</h1>"
    end
  end

  describe "POST /accounts/reset_password" do
    @tag :capture_log
    test "sends a new reset password token", %{conn: conn, account: account} do
      conn =
        post(conn, Routes.account_reset_password_path(conn, :create), %{
          "account" => %{"email" => account.email}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      assert Repo.get_by!(Accounts.AccountToken, account_id: account.id).context == "reset_password"
    end

    test "does not send reset password token if email is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.account_reset_password_path(conn, :create), %{
          "account" => %{"email" => "unknown@example.com"}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      assert Repo.all(Accounts.AccountToken) == []
    end
  end

  describe "GET /accounts/reset_password/:token" do
    setup %{account: account} do
      token =
        extract_account_token(fn url ->
          Accounts.deliver_account_reset_password_instructions(account, url)
        end)

      %{token: token}
    end

    test "renders reset password", %{conn: conn, token: token} do
      conn = get(conn, Routes.account_reset_password_path(conn, :edit, token))
      assert html_response(conn, 200) =~ "<h1>Reset password</h1>"
    end

    test "does not render reset password with invalid token", %{conn: conn} do
      conn = get(conn, Routes.account_reset_password_path(conn, :edit, "oops"))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) =~ "Reset password link is invalid or it has expired"
    end
  end

  describe "PUT /accounts/reset_password/:token" do
    setup %{account: account} do
      token =
        extract_account_token(fn url ->
          Accounts.deliver_account_reset_password_instructions(account, url)
        end)

      %{token: token}
    end

    test "resets password once", %{conn: conn, account: account, token: token} do
      conn =
        put(conn, Routes.account_reset_password_path(conn, :update, token), %{
          "account" => %{
            "password" => "new valid password",
            "password_confirmation" => "new valid password"
          }
        })

      assert redirected_to(conn) == Routes.account_session_path(conn, :new)
      refute get_session(conn, :account_token)
      assert get_flash(conn, :info) =~ "Password reset successfully"
      assert Accounts.get_account_by_email_and_password(account.email, "new valid password")
    end

    test "does not reset password on invalid data", %{conn: conn, token: token} do
      conn =
        put(conn, Routes.account_reset_password_path(conn, :update, token), %{
          "account" => %{
            "password" => "too short",
            "password_confirmation" => "does not match"
          }
        })

      response = html_response(conn, 200)
      assert response =~ "<h1>Reset password</h1>"
      assert response =~ "should be at least 12 character(s)"
      assert response =~ "does not match password"
    end

    test "does not reset password with invalid token", %{conn: conn} do
      conn = put(conn, Routes.account_reset_password_path(conn, :update, "oops"))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) =~ "Reset password link is invalid or it has expired"
    end
  end
end
