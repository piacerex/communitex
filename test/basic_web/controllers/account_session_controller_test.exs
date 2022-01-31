defmodule BasicWeb.AccountSessionControllerTest do
  use BasicWeb.ConnCase, async: true

  import Basic.AccountsFixtures

  setup do
    %{account: account_fixture()}
  end

  describe "GET /accounts/log_in" do
    test "renders log in page", %{conn: conn} do
      conn = get(conn, Routes.account_session_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "<h1>Log in</h1>"
      assert response =~ "Register</a>"
      assert response =~ "Forgot your password?</a>"
    end

    test "redirects if already logged in", %{conn: conn, account: account} do
      conn = conn |> log_in_account(account) |> get(Routes.account_session_path(conn, :new))
      assert redirected_to(conn) == "/"
    end
  end

  describe "POST /accounts/log_in" do
    test "logs the account in", %{conn: conn, account: account} do
      conn =
        post(conn, Routes.account_session_path(conn, :create), %{
          "account" => %{"email" => account.email, "password" => valid_account_password()}
        })

      assert get_session(conn, :account_token)
      assert redirected_to(conn) == "/"

      # Now do a logged in request and assert on the menu
      conn = get(conn, "/")
      response = html_response(conn, 200)
      assert response =~ account.email
      assert response =~ "Settings</a>"
      assert response =~ "Log out</a>"
    end

    test "logs the account in with remember me", %{conn: conn, account: account} do
      conn =
        post(conn, Routes.account_session_path(conn, :create), %{
          "account" => %{
            "email" => account.email,
            "password" => valid_account_password(),
            "remember_me" => "true"
          }
        })

      assert conn.resp_cookies["_basic_web_account_remember_me"]
      assert redirected_to(conn) == "/"
    end

    test "logs the account in with return to", %{conn: conn, account: account} do
      conn =
        conn
        |> init_test_session(account_return_to: "/foo/bar")
        |> post(Routes.account_session_path(conn, :create), %{
          "account" => %{
            "email" => account.email,
            "password" => valid_account_password()
          }
        })

      assert redirected_to(conn) == "/foo/bar"
    end

    test "emits error message with invalid credentials", %{conn: conn, account: account} do
      conn =
        post(conn, Routes.account_session_path(conn, :create), %{
          "account" => %{"email" => account.email, "password" => "invalid_password"}
        })

      response = html_response(conn, 200)
      assert response =~ "<h1>Log in</h1>"
      assert response =~ "Invalid email or password"
    end
  end

  describe "DELETE /accounts/log_out" do
    test "logs the account out", %{conn: conn, account: account} do
      conn = conn |> log_in_account(account) |> delete(Routes.account_session_path(conn, :delete))
      assert redirected_to(conn) == "/"
      refute get_session(conn, :account_token)
      assert get_flash(conn, :info) =~ "Logged out successfully"
    end

    test "succeeds even if the account is not logged in", %{conn: conn} do
      conn = delete(conn, Routes.account_session_path(conn, :delete))
      assert redirected_to(conn) == "/"
      refute get_session(conn, :account_token)
      assert get_flash(conn, :info) =~ "Logged out successfully"
    end
  end
end
