defmodule Basic.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Basic.Repo

  alias Basic.Accounts.{Account, AccountToken, AccountNotifier}

  ## Database getters

  @doc """
  Gets a account by email.

  ## Examples

      iex> get_account_by_email("foo@example.com")
      %Account{}

      iex> get_account_by_email("unknown@example.com")
      nil

  """
  def get_account_by_email(email) when is_binary(email) do
    Repo.get_by(Account, email: email)
  end

  @doc """
  Gets a account by email and password.

  ## Examples

      iex> get_account_by_email_and_password("foo@example.com", "correct_password")
      %Account{}

      iex> get_account_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  def get_account_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    account = Repo.get_by(Account, email: email)
    if Account.valid_password?(account, password), do: account
  end

  @doc """
  Gets a single account.

  Raises `Ecto.NoResultsError` if the Account does not exist.

  ## Examples

      iex> get_account!(123)
      %Account{}

      iex> get_account!(456)
      ** (Ecto.NoResultsError)

  """
  def get_account!(id), do: Repo.get!(Account, id)

  ## Account registration

  @doc """
  Registers a account.

  ## Examples

      iex> register_account(%{field: value})
      {:ok, %Account{}}

      iex> register_account(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_account(attrs) do
    %Account{}
    |> Account.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking account changes.

  ## Examples

      iex> change_account_registration(account)
      %Ecto.Changeset{data: %Account{}}

  """
  def change_account_registration(%Account{} = account, attrs \\ %{}) do
    Account.registration_changeset(account, attrs, hash_password: false)
  end

  ## Settings

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the account email.

  ## Examples

      iex> change_account_email(account)
      %Ecto.Changeset{data: %Account{}}

  """
  def change_account_email(account, attrs \\ %{}) do
    Account.email_changeset(account, attrs)
  end

  @doc """
  Emulates that the email will change without actually changing
  it in the database.

  ## Examples

      iex> apply_account_email(account, "valid password", %{email: ...})
      {:ok, %Account{}}

      iex> apply_account_email(account, "invalid password", %{email: ...})
      {:error, %Ecto.Changeset{}}

  """
  def apply_account_email(account, password, attrs) do
    account
    |> Account.email_changeset(attrs)
    |> Account.validate_current_password(password)
    |> Ecto.Changeset.apply_action(:update)
  end

  @doc """
  Updates the account email using the given token.

  If the token matches, the account email is updated and the token is deleted.
  The confirmed_at date is also updated to the current time.
  """
  def update_account_email(account, token) do
    context = "change:#{account.email}"

    with {:ok, query} <- AccountToken.verify_change_email_token_query(token, context),
         %AccountToken{sent_to: email} <- Repo.one(query),
         {:ok, _} <- Repo.transaction(account_email_multi(account, email, context)) do
      :ok
    else
      _ -> :error
    end
  end

  defp account_email_multi(account, email, context) do
    changeset =
      account
      |> Account.email_changeset(%{email: email})
      |> Account.confirm_changeset()

    Ecto.Multi.new()
    |> Ecto.Multi.update(:account, changeset)
    |> Ecto.Multi.delete_all(:tokens, AccountToken.account_and_contexts_query(account, [context]))
  end

  @doc """
  Delivers the update email instructions to the given account.

  ## Examples

      iex> deliver_update_email_instructions(account, current_email, &Routes.account_update_email_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_update_email_instructions(%Account{} = account, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    {encoded_token, account_token} = AccountToken.build_email_token(account, "change:#{current_email}")

    Repo.insert!(account_token)
    AccountNotifier.deliver_update_email_instructions(account, update_email_url_fun.(encoded_token))
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the account password.

  ## Examples

      iex> change_account_password(account)
      %Ecto.Changeset{data: %Account{}}

  """
  def change_account_password(account, attrs \\ %{}) do
    Account.password_changeset(account, attrs, hash_password: false)
  end

  @doc """
  Updates the account password.

  ## Examples

      iex> update_account_password(account, "valid password", %{password: ...})
      {:ok, %Account{}}

      iex> update_account_password(account, "invalid password", %{password: ...})
      {:error, %Ecto.Changeset{}}

  """
  def update_account_password(account, password, attrs) do
    changeset =
      account
      |> Account.password_changeset(attrs)
      |> Account.validate_current_password(password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:account, changeset)
    |> Ecto.Multi.delete_all(:tokens, AccountToken.account_and_contexts_query(account, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{account: account}} -> {:ok, account}
      {:error, :account, changeset, _} -> {:error, changeset}
    end
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_account_session_token(account) do
    {token, account_token} = AccountToken.build_session_token(account)
    Repo.insert!(account_token)
    token
  end

  @doc """
  Gets the account with the given signed token.
  """
  def get_account_by_session_token(token) do
    {:ok, query} = AccountToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_session_token(token) do
    Repo.delete_all(AccountToken.token_and_context_query(token, "session"))
    :ok
  end

  ## Confirmation

  @doc """
  Delivers the confirmation email instructions to the given account.

  ## Examples

      iex> deliver_account_confirmation_instructions(account, &Routes.account_confirmation_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

      iex> deliver_account_confirmation_instructions(confirmed_account, &Routes.account_confirmation_url(conn, :edit, &1))
      {:error, :already_confirmed}

  """
  def deliver_account_confirmation_instructions(%Account{} = account, confirmation_url_fun)
      when is_function(confirmation_url_fun, 1) do
    if account.confirmed_at do
      {:error, :already_confirmed}
    else
      {encoded_token, account_token} = AccountToken.build_email_token(account, "confirm")
      Repo.insert!(account_token)
      AccountNotifier.deliver_confirmation_instructions(account, confirmation_url_fun.(encoded_token))
    end
  end

  @doc """
  Confirms a account by the given token.

  If the token matches, the account account is marked as confirmed
  and the token is deleted.
  """
  def confirm_account(token) do
    with {:ok, query} <- AccountToken.verify_email_token_query(token, "confirm"),
         %Account{} = account <- Repo.one(query),
         {:ok, %{account: account}} <- Repo.transaction(confirm_account_multi(account)) do
      {:ok, account}
    else
      _ -> :error
    end
  end

  defp confirm_account_multi(account) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:account, Account.confirm_changeset(account))
    |> Ecto.Multi.delete_all(:tokens, AccountToken.account_and_contexts_query(account, ["confirm"]))
  end

  ## Reset password

  @doc """
  Delivers the reset password email to the given account.

  ## Examples

      iex> deliver_account_reset_password_instructions(account, &Routes.account_reset_password_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_account_reset_password_instructions(%Account{} = account, reset_password_url_fun)
      when is_function(reset_password_url_fun, 1) do
    {encoded_token, account_token} = AccountToken.build_email_token(account, "reset_password")
    Repo.insert!(account_token)
    AccountNotifier.deliver_reset_password_instructions(account, reset_password_url_fun.(encoded_token))
  end

  @doc """
  Gets the account by reset password token.

  ## Examples

      iex> get_account_by_reset_password_token("validtoken")
      %Account{}

      iex> get_account_by_reset_password_token("invalidtoken")
      nil

  """
  def get_account_by_reset_password_token(token) do
    with {:ok, query} <- AccountToken.verify_email_token_query(token, "reset_password"),
         %Account{} = account <- Repo.one(query) do
      account
    else
      _ -> nil
    end
  end

  @doc """
  Resets the account password.

  ## Examples

      iex> reset_account_password(account, %{password: "new long password", password_confirmation: "new long password"})
      {:ok, %Account{}}

      iex> reset_account_password(account, %{password: "valid", password_confirmation: "not the same"})
      {:error, %Ecto.Changeset{}}

  """
  def reset_account_password(account, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:account, Account.password_changeset(account, attrs))
    |> Ecto.Multi.delete_all(:tokens, AccountToken.account_and_contexts_query(account, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{account: account}} -> {:ok, account}
      {:error, :account, changeset, _} -> {:error, changeset}
    end
  end

  alias Basic.Accounts.Account

  @doc """
  Returns the list of accounts.

  ## Examples

      iex> list_accounts()
      [%Account{}, ...]

  """
  def list_accounts do
    Repo.all(Account)
  end

  @doc """
  Creates a account.

  ## Examples

      iex> create_account(%{field: value})
      {:ok, %Account{}}

      iex> create_account(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_account(attrs \\ %{}) do
    %Account{}
    |> Account.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a account.

  ## Examples

      iex> update_account(account, %{field: new_value})
      {:ok, %Account{}}

      iex> update_account(account, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_account(%Account{} = account, attrs) do
    account
    |> Account.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a account.

  ## Examples

      iex> delete_account(account)
      {:ok, %Account{}}

      iex> delete_account(account)
      {:error, %Ecto.Changeset{}}

  """
  def delete_account(%Account{} = account) do
    Repo.delete(account)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking account changes.

  ## Examples

      iex> change_account(account)
      %Ecto.Changeset{data: %Account{}}

  """
  def change_account(%Account{} = account, attrs \\ %{}) do
    Account.changeset(account, attrs)
  end
end
