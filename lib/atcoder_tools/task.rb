require 'open-uri'
require 'fileutils'
require 'nokogiri'
require 'erb'

# module Atcoder
  class Task
    def initialize(contest, name)
      @contest = contest
      @name = name
      @tests = []
      @test_outputs = []
    end

    def url
      "https://atcoder.jp/contests/#{@contest.name}/tasks/#{@contest.name}_#{@name}"
    end

    def task_file_path
      "#{@contest.name}/#{@name}.rb"
    end

    def test_file_path
      ".atcoder/#{@contest.name}/#{@name}/spec.rb"
    end

    def create!
      html = URI.open(url) do |f|
        charset = f.charset
        f.read
      end

      doc = Nokogiri::HTML.parse(html, nil, 'utf8')
      samples = doc.css('.lang-ja > .part > section > pre').map { |e| e.children.text }
      inputs, outputs = samples.partition.with_index { |_sample, i| i.even? }

      erb = ERB.new(File.read(File.dirname(__dir__)+"/atcoder_tools/sources/task.rb.erb"))
      File.write(task_file_path, erb.result(binding))
    end

    def run
      read_meta_data
      update_spec
      if @mode == "DEBUG"
        io = IO.popen("ruby #{task_file_path}", "w+")
        io.puts(@tests[0][:input])
        io.close_write
        puts io.readlines
      end
      if @mode == "RUN"
        system("echo put your inputs")
        system("ruby #{task_file_path}")
      end
      if @mode == "TEST"
        system("bundle exec rspec #{test_file_path}")
      end
    end

    def read_meta_data
      meta_flag = false
      test_no = nil
      tests = []
      mode = nil
      File.foreach(task_file_path) do |line|
        line.chomp!
        if line == "# METADATA::START"
          meta_flag = true
          next
        end
        if line == "# METADATA::FINISH"
          meta_flag = false
          next
        end
        unless meta_flag
          next
        end
        if line =~ /\#\stest-/
          test_no = line.scan(/\#\stest-(\d+)/)[0][0].to_i
          tests.push({ no: test_no })
        end
        if line =~ /\#\sinput:/
          test = tests.find{|test| test[:no] == test_no}
          test.merge!({ input: line.scan(/\#\sinput\:\s\"(.*)\"/)[0][0] })
        end
        if line =~ /\#\soutput:/
          test = tests.find{|test| test[:no] == test_no}
          test.merge!({ output: line.scan(/\#\soutput\:\s\"(.*)\"/)[0][0] })
        end
        if line =~ /\#\sMODE:/
          mode = line.scan(/\#\sMODE:\s(.+)/)[0][0]
        end
      end
      @tests = tests
      @mode = mode
    end

    def update_spec
      FileUtils.mkdir_p ".atcoder/#{@contest.name}/#{@name}"
      erb = ERB.new(File.read(File.dirname(__dir__)+"/atcoder_tools/sources/spec.rb.erb"))
      File.write(test_file_path, erb.result(binding))
    end

  end
# end