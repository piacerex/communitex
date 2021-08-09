# Communitex

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `npm install` inside the `assets` directory
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Usage

```
mix deps.get
mix ecto.create
mix ecto.migrate
cd assets
npm install
cd ..
iex -S mix phx.server
```

Please access the following URL with your browser.

```
http://localhost:4000/
```

If you want to try lightweight CMS "Sphere" that can edit Elixir template page, API, and HTML / CSS / JS on the Web, please access the following URL.

```
http://localhost:4000/sphere/edit
```

Next, start Web + DB development like below and you'll get a much more beautiful initial design than Phoenix's defaults.

```
mix phx.gen.live Blog Post posts title:string body:text
```

or

```
mix phx.gen.html Blog Post posts title:string body:text
```

## Setup Gigalixir

```
gigalixir pg:create --free
```

```
gigalixir run mix ecto.migrate
gigalixir ps:migrate
```

## Troubleshooting

### if ``mix ecto.migrate`` may fail on local

```
mix ecto.migrate --step 0
```

### if ``mix ecto.migrate`` may fail on Gigalixir

You perform the migration with specified time stamp as shown below, it will be restored.

```
gigalixir run mix ecto.migrate -v XXXXXXXXXXXXXX
```

or

```
gigalixir run mix ecto.migrate -n XXXXXXXXXXXXXX
```

For example:

```
gigalixir run mix ecto.migrate -v 20210309150445
```

### When Gigalixir is not updated with push

You perform pushing to Gigalixir with cache clean as shown below.

```
git -c http.extraheader="GIGALIXIR-CLEAN: true" push gigalixir
```

## Build processes (for communitex comitter only)

```
mix phx.new basic --live
mv basic communitex
```

```
mix phx.gen.auth Accounts User users

mix shotrize.apply
```

```
mix phx.gen.live Members Member members user_id:integer last_name:string first_name:string last_name_kana:string first_name_kana:string detail:text image:string birthday:datetime corporate_id:integer corporate_name:string industry:string department:string position:string deleted_at:datetime

mix phx.gen.live Accounts User users email:string hashed_password:string confirmed_at:datetime deleted_at:datetime

mix phx.gen.live Blogs Blog blogs post_id:string user_id:integer title:string image:binary tags:string body:text likes:integer views:integer deleted_at:datetime
```

```elixir:20210714094501_alter_users_auth_tables.exs
defmodule Basic.Repo.Migrations.AlterUsersAuthTables do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :deleted_at, :naive_datetime
    end
  end
end
```

```
rm priv/repo/migrations/*_create_users.exs
```
