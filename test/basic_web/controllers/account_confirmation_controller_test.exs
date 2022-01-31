defmodule BasicWeb.AccountConfirmationControllerTest do
  use BasicWeb.ConnCase, async: true

  alias Basic.Accounts
  alias Basic.Repo
  import Basic.AccountsFixtures

  setup do
    %{account: account_fixture()}
  end

  describe "GET /accounts/confirm" do
    test "renders the resend confirmation page", %{conn: conn} do
      conn = get(conn, Routes.account_confirmation_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "<h1>Resend confirmation instructions</h1>"
    end
  end

  describe "POST /accounts/confirm" do
    @tag :capture_log
    test "sends a new confirmation token", %{conn: conn, account: account} do
      conn =
        post(conn, Routes.account_confirmation_path(conn, :create), %{
          "account" => %{"email" => account.email}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      assert Repo.get_by!(Accounts.AccountToken, account_id: account.id).context == "confirm"
    end

    test "does not send confirmation token if Account is confirmed", %{conn: conn, account: account} do
      Repo.update!(Accounts.Account.confirm_changeset(account))

      conn =
        post(conn, Routes.account_confirmation_path(conn, :create), %{
          "account" => %{"email" => account.email}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      refute Repo.get_by(Accounts.AccountToken, account_id: account.id)
    end

    test "does not send confirmation token if email is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.account_confirmation_path(conn, :create), %{
          "account" => %{"email" => "unknown@example.com"}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      assert Repo.all(Accounts.AccountToken) == []
    end
  end

  describe "GET /accounts/confirm/:token" do
    test "renders the confirmation page", %{conn: conn} do
      conn = get(conn, Routes.account_confirmation_path(conn, :edit, "some-token"))
      response = html_response(conn, 200)
      assert response =~ "<h1>Confirm account</h1>"

      form_action = Routes.account_confirmation_path(conn, :update, "some-token")
      assert response =~ "action=\"#{form_action}\""
    end
  end

  describe "POST /accounts/confirm/:token" do
    test "confirms the given token once", %{conn: conn, account: account} do
      token =
        extract_account_token(fn url ->
          Accounts.deliver_account_confirmation_instructions(account, url)
        end)

      conn = post(conn, Routes.account_confirmation_path(conn, :update, token))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "Account confirmed successfully"
      assert Accounts.get_account!(account.id).confirmed_at
      refute get_session(conn, :account_token)
      assert Repo.all(Accounts.AccountToken) == []

      # When not logged in
      conn = post(conn, Routes.account_confirmation_path(conn, :update, token))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) =~ "Account confirmation link is invalid or it has expired"

      # When logged in
      conn =
        build_conn()
        |> log_in_account(account)
        |> post(Routes.account_confirmation_path(conn, :update, token))

      assert redirected_to(conn) == "/"
      refute get_flash(conn, :error)
    end

    test "does not confirm email with invalid token", %{conn: conn, account: account} do
      conn = post(conn, Routes.account_confirmation_path(conn, :update, "oops"))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) =~ "Account confirmation link is invalid or it has expired"
      refute Accounts.get_account!(account.id).confirmed_at
    end
  end
end
