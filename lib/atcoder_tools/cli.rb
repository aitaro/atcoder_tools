
require "thor"
require 'fileutils'
require "listen"
require_relative 'contest'
require_relative 'task'

module AtcoderTools
  class CLI < Thor
    desc 'create [contest name]', 'create contest workspace'
    def create(contest_name)
      contest = Contest.new(contest_name)
      contest.create!
  
      puts 'successfully created'
    end

    desc 'start', 'start run'
    def start
      # system('bundle exec guard -d --guardfile .atcoder/Guardfile')
      listener = Listen.to('.', ignore: /.atcoder\/.*/) do |modified, added, removed|
        # puts "modified absolute path: #{modified}"
        # puts "added absolute path: #{added}"
        # puts "removed absolute path: #{removed}"
        if modified[0]
          contest_name ,task_name = modified[0].split('/')[-2..-1]
          task_name = task_name[..-4] # .rb抜き出し

          puts("#{contest_name}/#{task_name}.rb was changed")

          contest = Contest.new(contest_name)
          # thor と名前空間がかぶっているため
          task = ::Task.new(contest, task_name)
          task.run
        end
      end
      listener.start # not blocking
      sleep
    end

    desc 'submit [contest name]', 'submit'
    def submit(contest_name, task_name)
      puts("まだ実装してないよ！")
    end

    desc 'delete [contest name]', 'delete'
    def delete(contest_name)
      FileUtils.rm_rf(contest_name)
      FileUtils.rm_rf(".atcoder/#{contest_name}")      
      puts 'successfully deleted'
    end
  end
end