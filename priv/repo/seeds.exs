# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Basic.Repo.insert!(%Basic.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Basic.Repo
alias Basic.Accounts.User
alias Basic.Organizations.Organization
alias Basic.Members.Member
alias Basic.Grants.Grant

Repo.insert!(%User{email: "admin@communitex.org", hashed_password: "$pbkdf2-sha512$160000$KV/lR7sJQx5BHK9aRCA8sA$EZs4nue1WlDhuA2kjZL80hRU4lLmFJXu8JNzl8PMiRlOmiJz9PizPUabBgnQSoKhVrQ7U58C1Ii3qi96LSIqdA", confirmed_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)})
Repo.insert!(%Organization{name: "システム管理者グループ"})
Repo.insert!(%Member{user_id: 1, organization_id: 1})
Repo.insert!(%Grant{user_id: 1, organization_id: 1, role: "SystemAdmin"})
