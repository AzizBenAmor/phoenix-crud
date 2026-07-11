defmodule UserManager.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :email, :string
    field :phone, :string
    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :phone])
    |> validate_required([:name, :email, :phone])
    |> validate_length(:phone, min: 10, max: 15)
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
  end
end
