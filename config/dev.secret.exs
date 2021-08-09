# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
use Mix.Config

config :sphere,
  mail_url_domain:  "http://localhost:4000",
  mail_from:        "noreply@communitex.org",
  content_root:     "/",
  content_folder:   "content/communitex.org",
  github_url:       "https://github.com/piacerex/communitex.org",
  local_root:       File.cwd!,
  local_check_file: "index.html"

# Mailer Setting

# Browsing mail from browser access to /sent_emails
#config :basic, Basic.Mailer, adapter: Bamboo.LocalAdapter

# smtp example
# config :basic, Basic.Mailer,
#  adapter: Bamboo.SMTPAdapter,
#  server: "",
#  hostname: "communitex.org",
#  port: 21,
#  username: "noreply@communitex.org",
#  password: "",
#  tls: :if_available,
#  allowed_tls_versions: [:tlsv1, :"tlsv1.1", :"tlsv1.2"],
#  ssl: false,
#  retries: 1,
#  no_mx_lookups: false,
#  auth: :if_available
