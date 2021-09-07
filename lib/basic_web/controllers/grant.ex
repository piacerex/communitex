defmodule BasicWeb.Grant do
  import Plug.Conn
  import Phoenix.Controller

  alias Basic.Grants
  alias BasicWeb.Router.Helpers, as: Routes

  def check(conn, needs, roles) do
    needs = case needs do
      nil -> %{display: "管理者"}
      needs -> needs
    end
    case conn.assigns[:current_user] do
      current_user -> 
        case Grants.find_user_grants!(current_user.id, roles |> Enum.map(& &1.name)) do
          [] -> 
            conn
            |> put_flash(:error, "#{needs.display}権限のあるユーザでログインし直してください")
            |> redirect(to: Routes.user_session_path(conn, :new))
            |> halt()
          _ -> 
            conn
        end
      _ -> 
        conn
        |> put_flash(:error, "本ページにアクセスする際は、ログインを行ってください")
        |> redirect(to: Routes.user_session_path(conn, :new))
        |> halt()
    end
  end

  def content_editor_grant(conn, _opts), do: check(conn, Grants.content_editor(), [Grants.system_admin(), Grants.content_editor()])
  def distributor_admin_grant(conn, _opts), do: check(conn, Grants.distributor_admin(), [Grants.system_admin(), Grants.distributor_admin(), Grants.organization_admin()])
  def agency_admin_grant(conn, _opts), do: check(conn, Grants.agency_admin(), [Grants.system_admin(), Grants.agency_admin(), Grants.organization_admin()])
  def organization_admin_grant(conn, _opts), do: check(conn, Grants.organization_admin(), [Grants.system_admin(), Grants.organization_admin()])
  def any_admin_grant(conn, _opts), do: check(conn, nil, Grants.roles())
end
