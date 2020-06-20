require 'open-uri'
require 'fileutils'
require 'nokogiri'
require 'erb'
require_relative 'task'

class Contest
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def url(task_name)
    "https://atcoder.jp/contests/#{@name}/tasks/#{@name}_#{task_name}"
  end

  def create!
    FileUtils.mkdir_p @name
    tasks = ['a','b','c','d','e','f'].map{|task_name| Task.new(self, task_name)}
    tasks.map(&:create!)
  end

end