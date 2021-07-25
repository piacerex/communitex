defmodule Basic.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Inspect, except: [:password]}
  schema "users" do
    field :email, :string
    field :password, :string, virtual: true
    field :hashed_password, :string
    field :confirmed_at, :naive_datetime
    field :deleted_at, :naive_datetime

    timestamps()
  end

  @doc """
  A user changeset for registration.

  It is important to validate the length of both email and password.
  Otherwise databases may truncate the email without warnings, which
  could lead to unpredictable or insecure behaviour. Long passwords may
  also be very expensive to hash for certain algorithms.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.
  """
  def registration_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:email, :password])
    |> validate_email()
    |> validate_password(opts)
  end

  defp validate_email(changeset) do
    changeset
    |> validate_required([:email], message: "必須項目ですのでご入力ください" )  # ユーザ登録／メールアドレス変更で既存メールアドレス
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "「@」がありません、もしくは半角スペースは使えません" )
    |> validate_length(:email, max: 160)
    |> unsafe_validate_unique(:email, Basic.Repo, message: "すでに登録済みです" )  # ユーザ登録／メールアドレス変更で既存メールアドレス
    |> unique_constraint(:email)
  end

  defp validate_password(changeset, opts) do
    changeset
    |> validate_required([:password], message: "必須項目ですのでご入力ください" )  # ユーザ登録／PW変更
    |> validate_length(:password, min: 8, message: "%{count}文字以上にしてください" )  # ユーザ登録／PW変更
    |> validate_length(:password, max: 16, message: "%{count}文字以内にしてください" )  # ユーザ登録／PW変更
    # |> validate_format(:password, ~r/[a-z]/, message: "at least one lower case character")
    # |> validate_format(:password, ~r/[A-Z]/, message: "at least one upper case character")
    # |> validate_format(:password, ~r/[!?@#$%^&*_0-9]/, message: "at least one digit or punctuation character")
    |> maybe_hash_password(opts)
  end

  defp maybe_hash_password(changeset, opts) do
    hash_password? = Keyword.get(opts, :hash_password, true)
    password = get_change(changeset, :password)

    if hash_password? && password && changeset.valid? do
      changeset
      |> put_change(:hashed_password, Pbkdf2.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end

  @doc """
  A user changeset for changing the email.

  It requires the email to change otherwise an error is added.
  """
  def email_changeset(user, attrs) do
    user
    |> cast(attrs, [:email])
    |> validate_email()
    |> case do
      %{changes: %{email: _}} = changeset -> changeset
      %{} = changeset -> add_error(changeset, :email, "変更ができません")  # メールアドレス変更で既存メールアドレス
    end
  end

  @doc """
  A user changeset for changing the password.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.
  """
  def password_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:password])
    |> validate_confirmation(:password, message: "パスワードが一致しません" )  # PW変更でPW確認不一致
    |> validate_password(opts)
  end

  @doc """
  Confirms the account by setting `confirmed_at`.
  """
  def confirm_changeset(user) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    change(user, confirmed_at: now)
  end

  @doc """
  Verifies the password.

  If there is no user or the user doesn't have a password, we call
  `Pbkdf2.no_user_verify/0` to avoid timing attacks.
  """
#  def valid_password?(%Basic.Accounts.User{hashed_password: hashed_password}, password)
#      when is_binary(hashed_password) and byte_size(password) > 0 do
  def valid_password?(%Basic.Accounts.User{hashed_password: hashed_password, confirmed_at: confirmed_at}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 and is_nil(confirmed_at) == false do
    Pbkdf2.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _) do
    Pbkdf2.no_user_verify()
    false
  end

  @doc """
  Validates the current password otherwise adds an error to the changeset.
  """
  def validate_current_password(changeset, password) do
    if valid_password?(changeset.data, password) do
      changeset
    else
      add_error(changeset, :current_password, "正しくありません")  # メールアドレス変更／PW変更でPW間違い
    end
  end
end
