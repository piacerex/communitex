defmodule BasicWeb.RestApiController do
  use BasicWeb, :controller
  alias Shotrize.Helper.Rest

  def index(conn, params) do
    {no_id_path, id} = Rest.separate_id(params["path_"])

    {new_params, template} =
      if id == nil do
        {
          params,
          "index.json"
        }
      else
        {
          params |> Map.put("id", id),
          "show.json"
        }
      end

    caller = "index()"

    try do
      result = execute("#{no_id_path}#{template}", caller, params: new_params)
      if is_tuple(result) do
        case result do
          {:ok, body} ->
            body = body |> to_map_if_struct  #|> inserted_to_created
            response(conn, caller, :created, body |> Jason.encode!())
          {_, body} ->
            response(
              conn,
              caller,
              :internal_server_error,
              elem(body, 1) |> inspect |> Rest.error_body()
            )
        end
      else
        body = cond do
          is_list(result) -> result |> Enum.map(&(&1 |> to_map_if_struct))  # |> inserted_to_created))
          true            -> result |> to_map_if_struct
        end
        response(conn, caller, :ok, body |> Jason.encode!())
      end
    rescue
      err ->
        response(conn, caller, :internal_server_error, err |> inspect |> Rest.error_body())
    end
  end

  def to_map_if_struct(value) when is_struct(value), do: value |> Map.from_struct |> Map.delete(:__meta__)
  def to_map_if_struct(value), do: value

  def inserted_to_created(map), do: map |> Map.put(:created_at, map.inserted_at) |> Map.delete(:inserted_at)

  def create(conn, params) do
    {no_id_path, _} = Rest.separate_id(params["path_"])

    # TODO：data.json.eexと列突合チェック
    caller = "create() on show"

    try do
      result = execute("#{no_id_path}create.json", "create() on write", params: params)
      case result do
        {:ok, body} ->
          body = body |> to_map_if_struct  #|> inserted_to_created
          response(conn, caller, :created, body |> Jason.encode!())
        {_, body} ->
          response(
            conn,
            caller,
            :internal_server_error,
            elem(body, 1) |> inspect |> Rest.error_body()
          )
      end
    rescue
      err ->
        response(conn, caller, :internal_server_error, err |> inspect |> Rest.error_body())
    end
  end

  def update(conn, params) do
    {no_id_path, id} = Rest.separate_id(params["path_"])

    if id == nil do
      response(conn, "update() on check", :not_found, %{error: "Not Found"} |> Jason.encode!())
    else
      new_params = params |> Map.put("id", id)

      # TODO：data.json.eexと列突合チェック
      caller = "update() on show"

      try do
        result = execute("#{no_id_path}update.json", "update() on write", params: new_params)

        case result do
          {:ok, body} ->
            body = body |> to_map_if_struct  #|> inserted_to_created
            response(conn, caller, :ok, body |> Jason.encode!())
          {_, body} ->
            response(
              conn,
              caller,
              :internal_server_error,
              elem(body, 1) |> inspect |> Rest.error_body()
          )
        end
      rescue
        err ->
          response(conn, caller, :internal_server_error, err |> inspect |> Rest.error_body())
      end
    end
  end

  def delete(conn, params) do
    # 未解決：[ "data" ]で渡しているが、paramsにはルートに格納されている（もう1階層[ "data" ]を入れても同じ）…何故？

    {no_id_path, id} = Rest.separate_id(params["path_"])

    if id == nil do
      response(conn, "update() on check", :not_found, "Not Found" |> Rest.error_body())
    else
      new_params = params |> Map.put("id", id)

      # TODO：data.json.eexと列突合チェック
      caller = "delete()"

      try do
        _result = execute("#{no_id_path}delete.json", caller, params: new_params)
        response(conn, caller, :no_content, "")
      rescue
        err ->
          response(conn, caller, :internal_server_error, err |> inspect |> Rest.error_body())
      end
    end
  end

  def execute(path, caller, params: params) do
    IO.puts("")
    IO.puts("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
    IO.puts("------------------------------")
    IO.puts("#{caller} > execute()")
    IO.puts("------------------------------")
    IO.inspect(params)
    IO.puts("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")

    File.read!("lib/basic_web/templates/api/rest/#{path}.eex")
    |> Shotrize.Helper.Eex.to_eex_string()
    |> EEx.eval_string(assigns: [params: params])
    |> Code.eval_string()
    |> elem(0)
  end

  def response(conn, caller, status, body) do
    IO.puts("")
    IO.puts("============================================================")
    IO.puts("------------------------------")
    IO.puts("#{caller} > response() status:#{status}")
    IO.puts("------------------------------")
    IO.inspect(body)
    IO.puts("============================================================")

    conn
    |> put_resp_header("content-type", "application/json; charset=utf-8")
    |> send_resp(status, body)
  end
end
