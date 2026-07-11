defmodule UserManagerWeb.PageController do
  use UserManagerWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
