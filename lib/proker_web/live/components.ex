defmodule ProkerWeb.Components do
  use ProkerWeb, :component

  def header(assigns) do
    ~H"""
    <%= link "<- Back Home", to: @home_path %>
    <h1 class="title">
      Room <%= @key %>
      &nbsp;
      <button class="button" onClick={"navigator.clipboard.writeText(window.location)"}>
        copy room link
      </button>
      <button class="button" phx-click={show_modal()}>edit room configuration</button>
    </h1>
    """
  end

  def configuration_modal(assigns) do
    ~H"""
    <div id="configurationModal" class="modal">
      <div class="modal-background"></div>
      <div class="modal-card">
        <header class="modal-card-head">
          <p class="modal-card-title">Room configuration</p>
          <button class="delete" aria-label="close" phx-click={hide_modal()}></button>
        </header>
        <form phx-submit="configure">
          <section class="modal-card-body">
            <div class="field">
              <label class="label">Anonymous reveal</label>
              <div class="control">
                <label class="checkbox">
                  <input type="checkbox" name="anonymous_reveal" checked={@config.anonymous_reveal} />
                  Hide participant names when revealing votes.
                </label>
              </div>
            </div>
            <div class="field">
              <label class="label">Voting buttons</label>
              <div class="control">
                <input class="input" type="text" name="voting_buttons" value={Enum.join(@config.voting_buttons, ", ")}>
              </div>
              <p class="help">Comma separated list of possible voting buttons.</p>
            </div>
          </section>
          <footer class="modal-card-foot">
            <input class="button is-primary" type="submit" value="Save config" phx-click={hide_modal()} />
          </footer>
        </form>
      </div>
    </div>
    """
  end

  def notifications(assigns) do
    ~H"""
    <div class="notifications">
      <%= for notification <- Enum.reverse(@notifications) do %>
        <div class="notification"><%= notification %></div>
      <% end %>
    </div>
    """
  end

  def voting(assigns) do
    ~H"""
    <div class="columns is-mobile is-multiline">
      <%= for val <- @config.voting_buttons do %>
        <div class="column">
          <button class="button is-large" phx-click="vote" phx-value-vote={ val }><%= val %></button>
        </div>
      <% end %>
      <br />
    </div>
    """
  end

  def players(assigns) do
    ~H"""
    <table class="table is-fullwidth">
      <%= for player <- @players do %>
      <tr class="list-item">
        <td><%= player.name %></td>
        <td><%= player.vote %></td>
      </tr>
      <% end %>
    </table>

    <%= if @user_joined do %>
      <button class="button is-primary" phx-click="reset_votes">Reset votes</button>
    <% else %>
      <form phx-submit="join">
        <div class="field">
          <label class="label" for="name">Your name</label>
          <div class="control">
            <input class="input" name="name" placeholder="John Doe" />
          </div>
          <%= if @form_error do %>
            <p class="help is-danger"><%= @form_error %></p>
          <% end %>
        </div>
        <input class="button is-primary" type="submit" value="Join" />
      </form>
    <% end %>
    """
  end

  defp hide_modal() do
    JS.remove_class("is-active", to: "#configurationModal")
  end

  defp show_modal() do
    JS.add_class("is-active", to: "#configurationModal")
  end
end
