defmodule BasicWeb.GrantLive.FormComponent do
  use BasicWeb, :live_component

  import Ecto.Changeset

  alias Basic.Grants

  @impl true
  def update(%{grant: grant} = assigns, socket) do
    changeset = case is_map(grant) do
      true -> Grants.change_grant(grant)
      _ -> Grants.change_grant(List.first(grant))
    end

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"grant" => grant_params}, socket) do
    candidate_users = case grant_params["user"] do
      "" ->
        case socket.assigns.candidate_users do
          "" -> ""
          _  -> socket.assigns.candidate_users
        end
      _  ->
        Grants.search_user(List.first(String.split(grant_params["user"])))
    end

    user_id = cond do
      Enum.count(candidate_users) == 1 -> Integer.to_string(List.first(candidate_users).user_id)
      true -> ""
    end

    role_list = cond do
      grant_params["organization_id"] == "" -> socket.assigns.role_list
      true -> Grants.get_role_list(socket.assigns.current_user_id, grant_params["organization_id"])
    end

    cond do
      user_id == "" ->
        changeset =
          List.first(socket.assigns.grant)
          |> Grants.change_grant(Map.put(grant_params, "user_id", user_id))
          |> Map.put(:action, :validate)

        {:noreply,
          socket
          |> assign(:changeset, changeset)
          |> assign(:candidate_users, candidate_users)
          |> assign(:selected_user, "")
          |> assign(:role_list, role_list)
        }

      grant_params["organization_id"] == "" or
      grant_params["role"] == "" ->
        changeset =
          List.first(socket.assigns.grant)
          |> Grants.change_grant(Map.put(grant_params, "user_id", user_id))
          |> Map.put(:action, :validate)

        {:noreply,
          socket
          |> assign(:changeset, changeset)
          |> assign(:candidate_users, candidate_users)
          |> assign(:selected_user, List.first(candidate_users).email <> " " <> List.first(candidate_users).last_name <> " " <> List.first(candidate_users).first_name)
          |> assign(:role_list, role_list)
        }

      true ->
        error = validate_params(Map.put(grant_params, "user_id", user_id))
        case error do
          "" -> changeset =
                  List.first(socket.assigns.grant)
                  |> Grants.change_grant(Map.put(grant_params, "user_id", user_id))
                  |> Map.put(:action, :validate)
                {:noreply,
                  socket
                  |> assign(:changeset, changeset)
                  |> assign(:candidate_users, candidate_users)
                  |> assign(:selected_organization, grant_params["organization_id"])
                  |> assign(:selected_user, List.first(candidate_users).email <> " " <> List.first(candidate_users).last_name <> " " <> List.first(candidate_users).first_name)
                  |> assign(:role_list, role_list)
                }
          _  -> changeset =
                  List.first(socket.assigns.grant)
                  |> Grants.change_grant(Map.put(grant_params, "user_id", user_id))
                  |> Map.put(:action, :validate)
                  |> add_error(:role, error)

                {:noreply,
                  socket
                  |> assign(:changeset, changeset)
                  |> assign(:candidate_users, candidate_users)
                  |> assign(:selected_organization, grant_params["organization_id"])
                  |> assign(:selected_user, List.first(candidate_users).email <> " " <> List.first(candidate_users).last_name <> " " <> List.first(candidate_users).first_name)
                  |> assign(:role_list, role_list)
                }
        end
    end
  end

  def handle_event("save", %{"grant" => grant_params}, socket) do
    user_id = cond do
      Enum.count(socket.assigns.candidate_users) == 1 ->
        Integer.to_string(List.first(socket.assigns.candidate_users).user_id)
      true -> ""
    end

    cond do
      user_id == "" or
      grant_params["organization_id"] == "" or
      grant_params["role"] == "" ->
        changeset =
          List.first(socket.assigns.grant)
          |> Grants.change_grant(Map.put(grant_params, "user_id", user_id))
          |> Map.put(:action, :validate)
        {:noreply, assign(socket, :changeset, changeset)}

      true ->
        error = validate_params(Map.put(grant_params, "user_id", user_id))
        cond do
          error == "" ->
            save_grant(socket, socket.assigns.action, Map.put(grant_params, "user_id", user_id))

          String.contains?(error, "削除されます") ->
            grant = Grants.get_grant!(List.first(Grants.get_grant_id(Map.put(grant_params, "user_id", user_id))).id)
            {:ok, _} = Grants.delete_grant(List.first(grant))

            {:noreply, assign(socket, :grants, Grants.list_grants_by_user_id(socket.assigns.current_user_id))}

            save_grant(socket, socket.assigns.action, Map.put(grant_params, "user_id", user_id))

          true ->
            changeset =
              List.first(socket.assigns.grant)
              |> Grants.change_grant(Map.put(grant_params, "user_id", user_id))
              |> Map.put(:action, :validate)
              |> add_error(:role, error)

            {:noreply, assign(socket, :changeset, changeset)}
        end
    end
  end

  defp save_grant(socket, :edit, grant_params) do
    case Grants.update_grant(List.first(socket.assigns.grant), grant_params) do
      {:ok, _grant} ->
        {:noreply,
         socket
         |> put_flash(:info, "Grant updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_grant(socket, :new, grant_params) do
    case Grants.create_grant(grant_params) do
      {:ok, _grant} ->
        {:noreply,
         socket
         |> put_flash(:info, "Grant created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def validate_params(params) do
    user_role = Grants.get_user_roles_for_validate(params["user_id"], params["organization_id"])

    if Grants.is_editor(params["user_id"]) do
      error = cond do
        Enum.member?(user_role, params["role"]) -> "同一データは登録できません"
        params["role"] == Grants.content_editor().name -> ""
        true -> "このユーザは#{Grants.content_editor().display}で登録してください"
      end
    else
      error = cond do
        user_role == "" ->
          ""
        true ->
          cond do
            Enum.member?(user_role, params["role"]) ->
              "同一データは登録できません"
            Enum.member?(user_role, Grants.system_admin().name) ->
              "#{Grants.system_admin().display}なので登録の必要はありません"
            Enum.member?(user_role, Grants.organization_admin().name) ->
              cond do
                params["role"] == Grants.system_admin().name ->
                  "より上位のロールなので、#{Grants.organization_admin().display}の登録は削除されます。よろしければ続行してください"
                params["role"] == Grants.content_editor().name ->
                  "#{Grants.organization_admin().display}で登録しています。#{Grants.content_editor().display}として登録はできません"
                true ->
                  "#{Grants.organization_admin().display}なので登録の必要はありません"
              end
            Enum.member?(user_role, Grants.distributor_admin().name) ->
              cond do
                params["role"] == Grants.agency_admin().name ->
                  ""
                params["role"] == Grants.content_editor().name ->
                  "#{Grants.distributor_admin().display}で登録しています。#{Grants.content_editor().display}として登録はできません"
                true ->
                  "より上位のロールなので、#{Grants.distributor_admin().display}の登録は削除されます。よろしければ続行してください"
              end
            Enum.member?(user_role, Grants.agency_admin().name) ->
              cond do
                params["role"] == Grants.distributor_admin().name ->
                  ""
                params["role"] == Grants.content_editor().name ->
                  "#{Grants.agency_admin().display}で登録しています。#{Grants.content_editor().display}として登録はできません"
                true ->
                  "より上位のロールなので、#{Grants.agency_admin().display}の登録は削除されます。よろしければ続行してください"
              end

            true ->
              cond do
                params["role"] == Grants.content_editor().name ->
                  user_roles = Grants.get_user_all_roles(params["user_id"])
                  cond do
                    Enum.empty?(user_roles) ->
                      ""
                    Enum.member?(user_roles, Grants.content_editor().name) ->
                      ""
                    true ->
                      "#{Grants.content_editor().display}として登録はできません"
                  end

                true ->
                  ""
              end
          end
      end
    end
  end

end
