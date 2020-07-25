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

    desc 'config [command]', 'configuration. 対話形式で始められます。'
    def config(config_key=nil)

      puts 'not yet'
    end

    desc 'create [contest name]', 'create contest workspace'
    def create(contest_name)
      contest = Contest.new(contest_name)
      contest.create!
  
      puts 'successfully created'
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
          task.run
        end
      end
      listener.start # not blocking
      sleep
    end

    desc 'submit', 'submit'
    def submit
      prompt = TTY::Prompt.new
      contest_name = prompt.select("Choose your submit contest?", ['abc169', 'abc170', 'abc171'])
      task_name = prompt.select("Choose your tesk?", ['a', 'b'])

      contest = Contest.new(contest_name)
      # thor と名前空間がかぶっているため
      task = ::Task.new(contest, task_name)
      Atcoder.submit(task)
    end

    desc 'delete [contest name]', 'delete'
    def delete(contest_name)
      FileUtils.rm_rf(contest_name)
      FileUtils.rm_rf(".atcoder/#{contest_name}")      
      puts 'successfully deleted'
    end
  end
end