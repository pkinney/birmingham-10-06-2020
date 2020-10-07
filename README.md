# LiveView/OTP Demo App

Presented at the October 2, 2020 [Birmingham Elixir Meetup](https://www.meetup.com/Birmingham-Elixir/events/273252345/).

## External APIs

During the presentation, I used a combination of `/etc/hosts` trickery and [Toxiproxy](https://github.com/Shopify/toxiproxy) to exagerate the external call latency.  In this Repo, I've changed the URLs to point directly to the external resources, so your delay in the UX will be much shorter.

## Usage

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `npm install` inside the `assets` directory
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.