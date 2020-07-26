require 'open-uri'
require 'fileutils'
require 'nokogiri'
require 'erb'

class Task
  attr_reader :contest, :name

  # contest引数はcontestクラス
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

  def compile_file_path
    "#{@contest.name}/#{@name}"
  end

  def test_file_path
    ".atcoder/#{@contest.name}/#{@name}/spec.rb"
  end

  def template_task_file_path
    extension = nil
    case @contest.language
    when 'ruby'
      extension = 'rb'
    when 'c++(gcc)'
      extension = 'cpp'
    end
    File.dirname(__dir__)+"/atcoder_tools/sources/task.#{extension}.erb"
  end

  def create!
    html = URI.open(url) do |f|
      charset = f.charset
      f.read
    end

    doc = Nokogiri::HTML.parse(html, nil, 'utf8')
    samples = doc.css('.lang-ja > .part > section > pre').map { |e| e.children.text }
    inputs, outputs = samples.partition.with_index { |_sample, i| i.even? }

    erb = ERB.new(File.read(template_task_file_path))
    File.write(task_file_path, erb.result(binding))
  end

  def run
    read_meta_data
    puts("#{@contest.name}/#{@name} is running in #{@mode} MODE")
    update_spec
    if @mode == "DEBUG"
      compile
      io = IO.popen(command, "w+")
      @tests[0][:inputs].each do |input|
        io.puts(input)
      end
      io.close_write
      puts io.readlines
    end
    if @mode == "RUN"
      compile
      system("echo put your inputs")
      system(command)
    end
    if @mode == "TEST"
      compile
      system("bundle exec rspec #{test_file_path}")
    end
  end

  def compile
    case contest.language
    when 'c++(gcc)'
      system("c++ #{task_file_path}")
    end
  end

  def command
    case contest.language
    when 'ruby'
      "ruby #{task_file_path}"
    when 'c++(gcc)'
      "#{compile_file_path}"
    end
  end

  def read_meta_data
    meta_flag = false
    test_no = nil
    tests = []
    mode = nil
    File.foreach(task_file_path) do |line|
      line.chomp!
      if line == "# METADATA::START" || line == "// METADATA::START"
        meta_flag = true
        next
      end
      if line == "# METADATA::FINISH" || line == "// METADATA::FINISH"
        meta_flag = false
        next
      end
      unless meta_flag
        next
      end
      if line =~ /(\#|\/\/)\stest-/
        test_no = line.scan(/(\#|\/\/)\stest-(\d+)/)[0][1].to_i
        tests.push({ no: test_no })
      end
      if line =~ /(\#|\/\/)\sinput:/
        test = tests.find{|test| test[:no] == test_no}
        input_str = line.scan(/(\#|\/\/)\sinput\:\s\"(.*)\"/)[0][1]
        inputs = input_str.chomp.split('\\n')
        test.merge!({ inputs: inputs })
      end
      if line =~ /(\#|\/\/)\soutput:/
        test = tests.find{|test| test[:no] == test_no}
        test.merge!({ output: line.scan(/(\#|\/\/)\soutput\:\s\"(.*)\"/)[0][1] })
      end
      if line =~ /(\#|\/\/)\sMODE:/
        mode = line.scan(/(\#|\/\/)\sMODE:\s(.+)/)[0][1]
      end
    end
    @tests = tests
    @mode = mode
  end

  def code
    File.read(task_file_path)
  end

  def update_spec
    FileUtils.mkdir_p ".atcoder/#{@contest.name}/#{@name}"
    erb = ERB.new(File.read(File.dirname(__dir__)+"/atcoder_tools/sources/spec.rb.erb"))
    File.write(test_file_path, erb.result(binding))
  end

end
