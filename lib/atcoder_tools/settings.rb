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
    @settings['current_contest'] && Contest.new(@settings['current_contest'])
  end

  def current_contest=(contest)
    case contest
    when String
      contest_name = contest
    when Contest
      contest_name = contest.name
    else
      raise ArgumentError, "引数は StringまたはContestです。"
    end
    @settings['current_contest'] = contest_name
  end

  def current_task
    current_contest && @settings['current_task'] && Task.new(current_contest, @settings['current_task'])
  end

  def current_task=(task)
    case task
    when String
      task_name = task
    when Task
      task_name = task.name
    else
      raise ArgumentError, "引数は StringまたはTaskです。"
    end
    @settings['current_task'] = task_name
  end

  def language
    @settings['language'] || 'ruby'
  end

  def language=(lang)
    @settings['language'] = lang
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