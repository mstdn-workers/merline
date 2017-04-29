require "rubygems"
require "bundler/setup"

require "mastodon"
require 'io/console'
require "readline"

require 'json'

APP_NAME = 'Merline; Mer timeline'
DEFAULT_CONFIG = {
  "host" => "mstdn-workers.com",
  "scopes" => "read write",
}
TOKEN_FILE_NAME = '.access_token'
DEFAULT_CONFIG_FILE_NAME = 'config.json'

stty_save = `stty -g`.chomp

Signal.trap(:INT) do
  system("stty", stty_save)
  puts ""
  exit 0
end

def reset_current_line
  print "\r\e[2K"
end

def load_config(config_file_name)
  if File.exist? config_file_name then
    JSON.load File.read config_file_name
  else
    save_config config_file_name, DEFAULT_CONFIG
    DEFAULT_CONFIG
  end
end

def save_config(config_file_name, config)
  File.write config_file_name, JSON.dump(config)
end

def user_email()
  Readline::readline('USER_EMAIL: ')
end
def user_password()
  STDIN.noecho { Readline.readline('PASSWORD: ').tap { puts } }
end

def access_token()
  def load_access_token()
    File.read(TOKEN_FILE_NAME).chomp
  end
  def save_access_token(token)
    File.write TOKEN_FILE_NAME, token
  end

  if File.exist? TOKEN_FILE_NAME then
    load_access_token
  else
    require "oauth2"
    base_url = 'https://' + $config["host"]
    scopes = $config["scopes"]
    client = Mastodon::REST::Client.new base_url: base_url
    app = client.create_app(APP_NAME, "urn:ietf:wg:oauth:2.0:oob", scopes)
    client = OAuth2::Client.new(app.client_id, app.client_secret, site: base_url)
    client.password.get_token(user_email, user_password, scope: scopes).token.tap { |t| save_access_token t }
  end
end


def init_app()
  config_file_name = DEFAULT_CONFIG_FILE_NAME
  save_config config_file_name, ($config = load_config config_file_name)
  base_url = 'https://' + $config["host"]
  return Mastodon::Streaming::Client.new(
           base_url: base_url,
           bearer_token: access_token
         ), Mastodon::REST::Client.new(
           base_url: base_url,
           bearer_token: access_token
         )
end

def readline_and_post(client)
  line = Readline::readline('')
  if line.nil? then
    reset_current_line
    return
  end
  # Readline::HISTORY.push(line)
  client.create_status(line)
end



# require 'pry'
# binding.pry

def status_to_string(status)
  return if not status.respond_to?(:account)
  return if not status.respond_to?(:content)
  account = status.account
  content = status.content
  return [
    [
      "[" + Time.iso8601(status.created_at).localtime.to_s + "]",
      account.display_name,
      "@" + account.acct
    ].join("\t"),
    content,
    ""
  ].join("\n")
end

stream_client, rest_client = init_app
tl_thread = Thread.new do
  stream_client.stream('public/local') do | status |
    if line = status_to_string(status) then
      reset_current_line
      puts line
    end
  end
end

post_thread = Thread.new do
  loop do
    readline_and_post rest_client
  end
end

tl_thread.join
post_thread.join
