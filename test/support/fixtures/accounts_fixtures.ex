defmodule Basic.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Basic.Accounts` context.
  """

  def unique_account_email, do: "account#{System.unique_integer()}@example.com"
  def valid_account_password, do: "hello world!"

  def valid_account_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_account_email(),
      password: valid_account_password()
    })
  end

  def account_fixture(attrs \\ %{}) do
    {:ok, account} =
      attrs
      |> valid_account_attributes()
      |> Basic.Accounts.register_account()

    account
  end

  def extract_account_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end

  @doc """
  Generate a account.
  """
  def account_fixture(attrs \\ %{}) do
    {:ok, account} =
      attrs
      |> Enum.into(%{
        confirmed_at: ~N[2022-01-23 05:24:00],
        deleted_at: ~N[2022-01-23 05:24:00],
        email: "some email",
        hashed_password: "some hashed_password"
      })
      |> Basic.Accounts.create_account()

    account
  end
end
