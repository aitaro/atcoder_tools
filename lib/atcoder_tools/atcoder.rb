require_relative 'settings'
require_relative 'log'

class Atcoder
  include Log

  def initialize
    @settings = Settings.new
    @agent = Mechanize.new
    @agent.user_agent_alias = 'Mac Mozilla'
  end

  def self.test_login(username, password)
    atcoder = Atcoder.new
    return atcoder.login(username=username, password=password)
  end

  def self.submit(task)
    atcoder = Atcoder.new
    atcoder.login
    atcoder.submit(task)
  end

  # 引数はtaskクラス
  def task_url(task)
    "https://atcoder.jp/contests/#{task.contest.name}/tasks/#{task.contest.name}_#{task.name}"
  end

  # 引数はcontest, taskクラス
  def submit(task)
    response = nil
    language_id = nil
    case task.contest.language
    when "ruby"
      language_id = "4049"
    when "c++(gcc)"
      language_id = "4003"
    end

      @agent.get(task_url(task)) do |page|
      # 1つ目のフォームはログアウト用なので2つ目を使用   
      form = page.forms.last
      form.field_with(name: 'data.LanguageId').value = language_id
      form.field_with(name: 'sourceCode').value = task.code
      response = @agent.submit(form)
    end

    if response.code.to_i == 200
      return true
    end
    return false
  end

  def login(username=nil, password=nil)

    username ||= @settings.credentials.username
    password ||= @settings.credentials.password

    response = nil
    log_debug "try login to atcoder"
    @agent.get("https://atcoder.jp/login") do |page|
      # 1つ目のフォームはログアウト用なので2つ目を使用
      form = page.forms.last
      form.field_with(name: 'username').value = username
      form.field_with(name: 'password').value = password
      response = @agent.submit(form)
    end

    # print(response.response)
    res = response.body.include?("Welcome, #{username}.")
    if res
      log_debug "login secceed!"
    else
      log_warn "login falied!"
    end

    return res
  end

end