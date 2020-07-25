require 'yaml'
require 'base64'

class Settings
  Credentials = Struct.new(:username, :password)

  def initialize
    if File.exist?(".atcoder/settings.yml")
      @settings = YAML.load_file(".atcoder/settings.yml")
    else
      @settings = {}
    end
  end

  def current_contest

  end

  def current_contest=()

  end

  def password=(password)
    @settings['password'] = Base64.strict_encode64(password)
  end

  def username=(username)
    @settings['username'] = username
  end

  def destroy_credentials!
    @settings.delete('username')
    @settings.delete('password')
  end

  def credentials
    unless @settings.key?('username') && @settings.key?('password')
      raise Error, "先にログインしてください！"
    end
    return Credentials.new(@settings['username'], Base64.decode64(@settings['password']))
  end

  def save!
    @settings['updated_at'] = Time.now
    YAML.dump(@settings, File.open('.atcoder/settings.yml', 'w'))
  end
end