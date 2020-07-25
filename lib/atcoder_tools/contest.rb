require 'open-uri'
require 'fileutils'
require 'nokogiri'
require 'erb'
require_relative 'task'
require_relative 'settings'

class Contest
  attr_reader :name

  def initialize(name)
    @name = name


  end

  def check_validity!
    # 実在するかcheck
    begin
      URI.open(url)
    rescue OpenURI::HTTPError
      raise 'contest name が存在しません。'
    end
  end

  def url
    "https://atcoder.jp/contests/#{@name}"
  end

  def submission_url
    "https://atcoder.jp/contests/#{@name}/submissions/me"
  end

  def create!
    FileUtils.mkdir_p @name
    tasks = ['a','b','c','d','e','f'].map{|task_name| Task.new(self, task_name)}
    tasks.map(&:create!)
    settings = Settings.new
    settings.current_contest = @name
    settings.save!
  end

  def self.list
    Dir.glob("./*").select{|dir| FileTest.directory?(dir)}.map{|dir| Contest.new dir[2..-1] }
  end

end