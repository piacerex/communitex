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
      from: Application.fetch_env!(:sphere, :mail_from),
      subject: subject,
      text_body: body  # html_bodyパラメータを指定すると、HTML解釈され、改行が消えるので注意
    )
    |> Basic.Mailer.deliver_now!()
    {:ok, %{to: to, body: body}}
  end

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(user, url), do: send_mail("user_registration.mail", user, url)

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(user, url), do: send_mail("user_reset_password.mail", user, url)

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url), do: send_mail("user_update_email.mail", user, url)

  def send_mail(filename, user, url) do
    url = String.replace(url, 
      [
        "http://example.com",      # UserConfirmationController.create() and others generates URL from config(EndPoint.url), but using LB, this is no good
        "http://example.com:4000", 
        "http://localhost:4000", 
      ], 
      Application.fetch_env!(:sphere, :mail_url_domain))
    parsed = Markdown.dispatch( filename, File.read!( Path.join( SphereShared.mail_folder(), filename ) ), nil, nil )

    if [] == Application.get_env(:basic, Basic.Mailer, []) do
      {:unsent, url}
    else
      deliver(user.email, parsed["title"], parsed["body"] |> EEx.eval_string(url: url))
    end

  end
end
