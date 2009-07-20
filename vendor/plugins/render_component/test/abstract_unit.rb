require 'rubygems'
require 'test/unit'
require 'action_controller'
require 'action_controller/test_process'
ActionController::Routing::Routes.reload rescue nil

$: << File.dirname(__FILE__) + "/../lib"
require File.dirname(__FILE__) + "/../init"
