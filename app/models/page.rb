# -*- coding: utf-8 -*-
require 'uri'

class Page

  attr_accessor :author, :body, :committed_date
  attr_reader :title, :errors, :history

  def initialize(title)
    @repo = Grit::Repo.new(REPOS_ROOT)
    @title = URI.unescape(title)
    @errors = {}
    @history = []
  end

  def id
    @title.to_permalink
  end

  def html_body
    @body.gsub!(/\[\[([\w |]+)\]\]/) do |m|
      title, link = $1.split('|')
      link = "/pages/#{URI.escape(title)}" unless link

      "[#{title}](#{link})"
    end

    # http://www.youtube.com/watch?v=vL7QNe6X3Gg
    #@body.gsub(/http:\/\/www\.youtube\.com\/watch\?v=[^ ]/) do |m|
    #  puts '----------------------------'
    #  puts m
    #  puts '----------------------------'
    #end

    markup = Markup.new(:markdown, @body)
    markup.to_html
  end

  def message
    "Page #{@title} updated"
  end

  def <<(body)
    @body = '' if @body.nil?
    @body << body
  end

  def save(message)
    path = REPOS_ROOT + '/' + @title

    File.open(path, 'w') do |f|
      f.print @body
    end

    Dir.chdir(REPOS_ROOT) { @repo.add(@title) }
    commit(message)
  end

  def destroy(message)
    Dir.chdir(REPOS_ROOT) { @repo.remove(@title) }
    commit(message)
  end

  def to_s
    @title
  end

  def to_param
    to_s
  end

  class << self

    def all
      tree = repo.tree
      pages = []
      for contents in tree.contents
        page = self.new(contents.name)
        page << contents.data
        #page.author = commit.author

        pages << page
      end

      pages
    end

    def find_by_title(title)
      title = URI.unescape(title)
      path = REPOS_ROOT + '/' + title
      return nil unless File.exists?(path)

      page = self.new(title)

      File.open(path, 'r') do |f|
        while line = f.gets
          page << line
        end
      end

      @r = repo
      Dir.chdir(REPOS_ROOT) { page.instance_variable_set('@history', @r.log(title)) }

      user_id = page.history.first.author.name.to_i
      if user_id == 0
        page.author = User.find(:first)
      else
        page.author = User.find(user_id)
      end

      page.committed_date = page.history.first.committed_date

      page
    end

    def find_by_commit_id(commit_id)
      commit = repo.commits(commit_id).first
      contents = commit.tree.contents.first
      page = self.new(contents.name)
      page << contents.data
      page.author = User.find(commit.author.name)
      page.committed_date = commit.committed_date

      #puts '----------------------'
      #puts page.title
      #puts page.body
      #puts commit.author.name
      #puts '----------------------'

      page
    end

    def search(words)
      words = words.split(/[ ]+/s).join(' -e ')

      Dir.chdir(REPOS_ROOT) { @results = `git grep -i --all-match -e #{words}` }

      pages = []
      loaded_pages = []
      @results.split(/\n/).each do |line|
        line.scan(/^([\w ]+):(.*)/) do |title, result|

          unless loaded_pages.include?(title)
            loaded_pages << title # necessary to not repeat pages
            page = Page.new(title)
            page << result
            pages << page
          end
        end
      end
      pages
    end

    def hashsum(title)
      hasher = Hasher.new('MD5', REPOS_ROOT + '/' + title)
      hasher.hashsum
    end

    private

    def repo
      Grit::Repo.new(REPOS_ROOT)
    end
  end

  private

  def commit(message)
    results = @repo.commit_index(message, :author => "#{@author.id} <#{@author.email}>")# "#{@author.name} <#{@author.email}>")

    unless results =~ /Created commit/
      Dir.chdir(REPOS_ROOT) { `git reset #{@title}` }
      return false
    end
    true
  end
end
