defmodule Basic.Accounts.UserNotifier do
  import Bamboo.Email

  # For simplicity, this module simply logs messages to the terminal.
  # You should replace it by a proper email or notification tool, such as:
  #
  #   * Swoosh - https://hexdocs.pm/swoosh
  #   * Bamboo - https://hexdocs.pm/bamboo
  #
  defp deliver(to, subject, body) do
#    require Logger
#    Logger.debug(body)
    new_email(
      to: to,
      from: "noreply@digi-dock.com",
      subject: subject,
      text_body: body  # html_bodyパラメータを指定すると、HTML解釈され、改行が消えるので注意
    )
    |> Basic.Mailer.deliver_now!()
    {:ok, %{to: to, body: body}}
  end

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(user, url) do
    url = url |> String.replace( "http://example.com:4000", "https://communitex.org" )  #TODO: クイックハック、直ったら消すこと
    deliver(user.email, "【communitex】会員登録完了のお知らせ", 
      File.read!( Path.join( SphereShared.mail_folder(), "user_registration.mail" ) ) |> EEx.eval_string( url: url ) )  #TODO: Sphereのロードの仕組みに乗せる
  end

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(user, url) do
    url = url |> String.replace( "http://example.com:4000", "https://communitex.org" )  #TODO: クイックハック、直ったら消すこと
    deliver(user.email, "【communitex】パスワードリセットのご案内", 
      File.read!( Path.join( SphereShared.mail_folder(), "user_reset_password.mail" ) ) |> EEx.eval_string( url: url ) )  #TODO: Sphereのロードの仕組みに乗せる
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url) do
IO.puts "--------------------------------------------------"
IO.inspect url
    url = url |> String.replace( "http://example.com:4000", "https://communitex.org" )  #TODO: クイックハック、直ったら消すこと
IO.puts "--------------------------------------------------"
IO.inspect url
IO.puts "--------------------------------------------------"
    deliver(user.email, "【communitex】登録情報変更のお知らせ", 
      File.read!( Path.join( SphereShared.mail_folder(), "user_update_email.mail" ) ) |> EEx.eval_string( url: url ) )  #TODO: Sphereのロードの仕組みに乗せる
  end
end
