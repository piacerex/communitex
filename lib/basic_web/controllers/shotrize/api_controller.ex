defmodule BasicWeb.ApiController do
  use BasicWeb, :controller
  alias Shotrize.Helper.Rest

  def index(conn, params) do
    path_ = params["path_"]
    content_path = if path_ == [], do: "index", else: Path.join(path_)

    try do
      result = execute("#{content_path}.json", "index()", params: params)

      if is_tuple(result) do
        response(conn, elem(result, 0), elem(result, 1) |> Jason.encode!())
      else
        response(conn, :ok, result |> Jason.encode!())
      end
    rescue
      err ->
        response(conn, :internal_server_error, err |> inspect |> Rest.error_body())
    end
  end

  def execute(path, caller, params: params) do
    IO.puts("")
    IO.puts("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
    IO.puts("------------------------------")
    IO.puts("#{caller} > execute()")
    IO.puts("------------------------------")
    IO.inspect(params)
    IO.puts("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")

    File.read!("lib/basic_web/templates/api/#{path}.eex")
    |> Shotrize.Helper.Eex.to_eex_string()
    |> EEx.eval_string(assigns: [params: params])
    |> Code.eval_string()
    |> elem(0)
  end

  def response(conn, status, body) do
    IO.puts("")
    IO.puts("================================================================================")
    IO.puts("------------------------------")
    IO.puts("response() status:#{status}")
    IO.puts("------------------------------")
    IO.inspect(body)
    IO.puts("================================================================================")

    conn
    |> put_resp_header("content-type", "application/json; charset=utf-8")
    |> send_resp(status, body)
  end
end
