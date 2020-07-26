require "thor"
require 'fileutils'
require "listen"
require 'mechanize'
require_relative 'contest'
require_relative 'task'
require_relative 'settings'
require_relative 'atcoder'
require "tty-prompt"
require_relative 'log'


module AtcoderTools
  class CLI < Thor
    include Log
    Prompt = TTY::Prompt.new
    desc 'login', 'login to atcoder'
    def login
      # 認証情報を書き込むので、gitignoreを設定する
      unless Dir.exist?('.atcoder')
        Dir.mkdir('.atcoder')
      end
      File.open(".atcoder/.gitignore", mode = "w"){|f|
        f.write("*")  # ファイルに書き込む
      }
      loop do
        prompt = TTY::Prompt.new
        username = prompt.ask("What is your atcoder username?", required: true)
        password = prompt.mask("What is your atcoder password?", required: true)
        puts ""
        log_info 'starting test login.'

        if Atcoder.test_login(username, password)
          settings = Settings.new
          settings.username = username
          settings.password = password
          settings.save!
          log_info 'OK!'
          break
        else
          log_error "Your username or password is invalid! try again!"
        end
      end
    end

    desc 'logout', 'logout from atcoder.'
    def logout
      settings = Settings.new
      settings.destroy_credentials!
      settings.save!
    end

    desc 'language [lang?]', '言語を選択できます。現在対応している言語は ruby, c++(gcc) です。'
    def language(lang='')
      unless ['ruby', 'c++(gcc)'].include?(lang)
        lang = Prompt.select("choose your default language.", ['ruby', 'c++(gcc)'])
      end

      # コマンドが通っているかテスト
      log_info "Checking path ..."
      res = case lang
            when 'ruby'
              !!system('ruby -v')
            when 'c++(gcc)'
              !!system('c++ -v')
            end

      unless res
        raise "Cannot find path of #{lang}. Is `$ #{lang} -v` working?"
      end

      settings = Settings.new
      settings.language = lang
      settings.save!
      puts
      log_info 'Default language successfully changed!'
    end

    desc 'create [contest name]', 'create contest workspace. contest name は actoderのurlより取得できます。(ex. abc173)'
    def create(contest_name)
      contest = Contest.new(contest_name)
      contest.check_validity!
      contest.create!
  
      log_info 'successfully created'
    end

    desc 'start', 'start run'
    def start
      listener = Listen.to('.', ignore: /.atcoder\/.*/) do |modified, added, removed|
        if modified[0]
          contest_name ,task_name = modified[0].split('/')[-2..-1]
          task_name = task_name[..-4] # .rbをぬく

          contest = Contest.new(contest_name)
          # thor と名前空間がかぶっているため
          task = ::Task.new(contest, task_name)
          # 最後に動かしたcontest, taskを記憶
          settings = Settings.new
          settings.current_contest = contest
          settings.current_task = task
          settings.save!

          task.run
        end
      end
      log_info 'started actoder_tools session.'
      listener.start
      sleep
    end

    desc 'submit', 'ソースコードを提出します。提出する問題は対話形式で指定できます。'
    def submit
      prompt = TTY::Prompt.new
      # contest_name = prompt.select("Choose your submit contest?", Contest.list.map(&:name))
      contest_name = Prompt.select("Choose your submit contest?") do |submit|
        Contest.list.each_with_index do |contest, i|
          submit.choice contest.name
          if Settings.new.current_contest&.name == contest.name
            submit.default i + 1
          end
        end
      end

      # contestによっては6種類ない可能性がある。
      task_list = ['a', 'b', 'c', 'd', 'e', 'f']
      task_name = prompt.select("Choose your tesk?") do |submit|
        task_list.each_with_index do |task, i|
          submit.choice task
          if Settings.new.current_task&.name == task
            submit.default i + 1
          end
        end
      end

      contest = Contest.new(contest_name)
      # thor と名前空間がかぶっているため
      task = ::Task.new(contest, task_name)
      Atcoder.submit(task)
    end

    desc 'delete [contest_name?]', 'delete'
    def delete(contest_name=nil)
      unless contest_name
        contest_name = Prompt.select("Choose your submit contest?") do |submit|
          Contest.list.each_with_index do |contest, i|
            submit.choice contest.name
            if Settings.new.current_contest&.name == contest.name
              submit.default i + 1
            end
          end
        end
      end
      FileUtils.rm_rf(contest_name)
      FileUtils.rm_rf(".atcoder/#{contest_name}")      
      puts 'successfully deleted'
    end
  end
end