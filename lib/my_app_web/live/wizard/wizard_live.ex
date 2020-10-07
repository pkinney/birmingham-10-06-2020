defmodule MyAppWeb.Wizard.WizardLive do
  use MyAppWeb, :live_view

  alias MyApp.Accounts
  alias Accounts.{Org, User}

  @impl true
  def mount(_, _, socket) do
    {:ok,
     socket
     |> assign(%{
       step: :org,
       org_changeset: Accounts.change_org(%Org{}),
       user_changeset: Accounts.change_user(%User{})
     })}
  end

  @impl true

  def render(%{step: :org} = assigns) do
    ~L"""
    <h2>Sign up for an account</h2><hr/>
    <%= f = form_for @org_changeset, "#", [phx_change: :validate_org, phx_submit: :save_org] %>
      <%= label f, :name, "Organization Name" %>
      <%= text_input f, :name %>
      <%= error_tag f, :name %>

      <div class="clearfix">
        <%= submit "Next", phx_disable_with: "Nexting...", class: "float-right" %>
      </div>
    </form>
    """
  end

  def render(%{step: :user} = assigns) do
    ~L"""
    <h2>Sign up for an account</h2><hr/>
    <%= f = form_for @user_changeset, "#", [phx_change: :validate_user, phx_submit: :save_user] %>
      <%= label f, :name, "Your Name" %>
      <%= text_input f, :name %>
      <%= error_tag f, :name %>

      <%= label f, :email, "Your Email" %>
      <%= email_input f, :email %>
      <%= error_tag f, :email %>

      <div class="clearfix">
        <%= submit "Sign Up", phx_disable_with: "Saving...", class: "float-right" %>
        <%= link "<- Back", to: {:javascript, "void(0);"}, phx_click: "back_to_org", class: "button button-clear" %>
      </div>
    </form>
    """
  end

  def render(%{step: :complete} = assigns) do
    ~L"""
    <h2>Sign up for an account</h2><hr/>
    <h3>All done!</h3>
    """
  end

  @impl true
  def handle_event("validate_org", %{"org" => org_params}, socket) do
    org_changeset =
      %Org{}
      |> Accounts.change_org(org_params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, org_changeset: org_changeset)}
  end

  def handle_event("validate_user", %{"user" => user_params}, socket) do
    user_changeset =
      %User{}
      |> Accounts.change_user(user_params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, user_changeset: user_changeset)}
  end

  def handle_event("save_org", %{"org" => org_params}, socket) do
    %Org{}
    |> Accounts.change_org(org_params)
    |> Map.put(:action, :insert)
    |> case do
      %{valid?: true} ->
        {:noreply, socket |> assign(:org_params, org_params) |> assign(:step, :user)}

      org_changeset ->
        {:noreply, assign(socket, org_changeset: org_changeset)}
    end
  end

  def handle_event("back_to_org", _, socket) do
    {:noreply, socket |> assign(:step, :org)}
  end

  def handle_event("save_user", %{"user" => user_params}, socket) do
    Accounts.create_org_with_admin(socket.assigns.org_params, user_params)
    |> case do
      {:error, :org, org_changeset, _} ->
        {:noreply, socket |> assign(:org_changeset, org_changeset) |> assign(:step, :org)}

      {:error, :user, user_changeset, _} ->
        {:noreply, socket |> assign(:user_changeset, user_changeset) |> assign(:step, :user)}

      {:ok, _} ->
        {:noreply,
         socket
         |> assign(:step, :complete)
         |> toast("Successfully created an organization and user.")}
    end
  end
end
