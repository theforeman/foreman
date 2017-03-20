require 'test_helper'

class FakeController < ApplicationController
  include Foreman::Controller::CsvResponder

  def index
    csv_response(Domain.unscoped, [:name])
  end
end

class Api::V2::FakeController < Api::V2::BaseController
  include Foreman::Controller::CsvResponder

  def index
    csv_response(Domain.unscoped, [:name])
  end
end

#add the fake controllers to the routes table
Rails.application.routes.disable_clear_and_finalize = true
Rails.application.routes.draw do
  get '/fake' => 'fake#index'
  get '/fake_api' => 'api/v2/fake#index'
end

class CsvResponderTest < ActionController::TestCase
  tests FakeController

  test "response is streamed correctly with right headers" do
    get :index, session: set_session_user
    assert_equal "text/csv; charset=utf-8", response.headers["Content-Type"]
    assert_equal "no-cache", response.headers["Cache-Control"]
    assert_equal "attachment; filename=\"fake-#{Date.today}.csv\"", response.headers["Content-Disposition"]
    buf = response.stream.instance_variable_get(:@buf)
    assert buf.is_a? Enumerator
    assert_equal "Name\n", buf.next
  end
end

class CsvApiResponderTest < ActionController::TestCase
  tests Api::V2::FakeController

  test "response is streamed correctly with right headers" do
    get :index, session: set_session_user
    assert_equal "text/csv; charset=utf-8", response.headers["Content-Type"]
    assert_equal "no-cache", response.headers["Cache-Control"]
    assert_equal "attachment; filename=\"fake-#{Date.today}.csv\"", response.headers["Content-Disposition"]
    buf = response.stream.instance_variable_get(:@buf)
    assert buf.is_a? Enumerator
    assert_equal "Name\n", buf.next
  end
end
