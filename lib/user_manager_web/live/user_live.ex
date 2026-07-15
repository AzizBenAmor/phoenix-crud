defmodule UserManagerWeb.UserLive.Index do
  use UserManagerWeb, :live_view

  alias UserManager.Accounts
  alias UserManager.Accounts.User

  def mount(_params, _session, socket) do
    users = Accounts.list_users()
    {:ok, assign(socket, :users, users)}
  end

  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <div class="flex items-center justify-between">
        <h1 class="text-2xl font-bold">Users</h1>
        <.link patch={~p"/users/new"} class="btn btn-primary">
          + New user
        </.link>
      </div>
      <div :if={@live_action in [:new, :edit]} class="card bg-base-100 shadow-md p-6 mb-6">
        <h2 class="text-xl font-semibold mb-4">
          {if @live_action == :new, do: "New User", else: "Edit User"}
        </h2>
        <.form for={@form} phx-change="validate" phx-submit="save" class="space-y-3">
          <.input field={@form[:name]} label="Name" />
          <.input field={@form[:email]} type="email" label="Email" />
          <.input field={@form[:phone]} label="Phone" />
          <div class="flex items-center gap-3 pt-2">
            <.button type="submit" variant="primary">Save</.button>
            <.link patch={~p"/users"} class="btn btn-ghost">Cancel</.link>
          </div>
        </.form>
      </div>
      <.table id="users" rows={@users}>
        <:col :let={user} label="Name">{user.name}</:col>
        <:col :let={user} label="Email">{user.email}</:col>
        <:col :let={user} label="Phone">{user.phone}</:col>
        <:action :let={user}>
          <.link patch={~p"/users/#{user.id}/edit"} class="btn btn-sm btn-ghost">
            Edit
          </.link>
          <.button  class="btn btn-sm btn-danger" phx-click="delete" phx-value-id={user.id} data-confirm="Are you sure?">
            Delete
          </.button>
        </:action>
      </.table>
    </div>
    """
  end

  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      socket.assigns.user
      |> Accounts.change_user(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    user = Accounts.get_user!(id)
    {:ok, _} = Accounts.delete_user(user)

    {:noreply, socket |> assign(:users, Accounts.list_users()) |> put_flash(:info, "User deleted successfully.")}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case socket.assigns.live_action do
      :new ->
        case Accounts.create_user(user_params) do
          {:ok, _user} ->
            {:noreply,
             socket
             |> put_flash(:info, "User created successfully.")
             |> push_patch(to: ~p"/users")}

          {:error, %Ecto.Changeset{} = changeset} ->
            {:noreply, assign(socket, :form, to_form(changeset))}
        end

      :edit ->
        case Accounts.update_user(socket.assigns.user, user_params) do
          {:ok, _user} ->
            {:noreply,
             socket
             |> put_flash(:info, "User updated successfully.")
             |> push_patch(to: ~p"/users")}

          {:error, %Ecto.Changeset{} = changeset} ->
            {:noreply, assign(socket, :form, to_form(changeset))}
        end
    end
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Users")
    |> assign(:user, nil)
    |> assign(:users, Accounts.list_users())
  end

  defp apply_action(socket, :new, _params) do
    user = %User{}
    socket
    |> assign(:page_title, "New User")
    |> assign(:user, user)
    |> assign(:form, to_form(Accounts.change_user(user)))
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    user = Accounts.get_user!(id)
    socket
    |> assign(:page_title, "Edit User")
    |> assign(:user, user)
    |> assign(:form, to_form(Accounts.change_user(user)))
  end
end
