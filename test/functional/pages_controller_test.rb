# -*- coding: utf-8 -*-
require 'test_helper'

class PagesControllerTest < ActionController::TestCase

  def test_index
    get :index

    assert_redirected_to root_url
  end

  def test_show
    get :show, :id => 'Título da Página'

    assert_response :success
  end
end
