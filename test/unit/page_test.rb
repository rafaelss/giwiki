# -*- coding: utf-8 -*-
require 'test_helper'

class PageTest < ActiveSupport::TestCase

  @@first = true

  def setup
    if @@first
      @@first = false
      `rm -rf #{RAILS_ROOT}/pages && mkdir #{RAILS_ROOT}/pages && cd #{RAILS_ROOT}/pages && git init`
    end

    @attributes = {
      :title => 'Titulo de Pagina',
      :body => 'conteudo da pagina'
    }

    @author = Grit::Actor.from_string('Rafael Souza <rafael.ssouza@gmail.com>')

    Grit.debug = false
  end

  def test_1_new
    repo = Page.new(@attributes[:title])
    assert_kind_of Page, repo
  end

  def test_2_add
    page = Page.new(@attributes[:title])
    page.author = @author
    page << @attributes[:body]
    assert page.save('criacao da pagina')
  end

  def test_3_find
    page = Page.find_by_title(@attributes[:title])
    assert_equal @attributes[:body], page.body
    assert_equal @author.name, page.author.name
    assert_equal @author.email, page.author.email
  end

  def test_4_change
    page = Page.find_by_title(@attributes[:title])
    assert_equal @attributes[:body], page.body

    page.body = 'Novo conteudo'
    page.save('conteudo alterado')

    page = Page.find_by_title(@attributes[:title])
    assert_equal 'Novo conteudo', page.body
  end

  def test_5_destroy
    page = Page.find_by_title(@attributes[:title])
    page.author = @author
    assert page.destroy('pagina apagada')

    page = Page.find_by_title(@attributes[:title])
    assert_nil page
  end

  def test_wiki_links
    page = Page.new('Wiki Links')
    page << '[[Wiki links]]'

    assert_match '<p><a href="/pages/Wiki%2520links">Wiki links</a></p>', page.html_body
  end

  #def test_youtube_embed_player
  #  page = Page.new('Youtube player')
  #  page << 'http://br.youtube.com/watch?v=60RzAR8I6kU'
  #
  #  assert_match /swfobject.embedSWF/, '<p><a href="/pages/Wiki%2520links">Wiki links</a></p>', page.html_body
  #end
end
