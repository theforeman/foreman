require File.join(File.dirname(__FILE__), 'test_helper')

class TestJail < Test::Unit::TestCase
  def setup
    @article = Article.new.to_jail
    @comment = @article.comments.first
  end

  def test_explicitly_allowed_methods_should_be_accessible
    assert_nothing_raised { @article.title }
  end

  def test_jail_instance_methods_should_be_accessible
    assert_nothing_raised { @article.author_name }
  end

  def test_sending_to_jail_to_an_object_should_return_a_jail
    assert_equal "Article::Jail", @article.class.name
  end

  def test_jail_instances_should_have_limited_methods
    expected = ["class", "inspect", "method_missing", "methods", "respond_to?", "to_jail", "to_s", "instance_variable_get"]
    objects.each do |object|
      assert_equal expected.sort, reject_pretty_methods(object.to_jail.methods.sort)
    end
  end

  def test_jail_classes_should_have_limited_methods
    expected = ["new", "methods", "name", "inherited", "method_added", "inspect",
                "allow", "allowed?", "allowed_methods", "init_allowed_methods",
                "<", # < needed in Rails Object#subclasses_of
                "ancestors", "==" # ancestors and == needed in Rails::Generator::Spec#lookup_class
               ]
    objects.each do |object|
      assert_equal expected.sort, reject_pretty_methods(object.to_jail.class.methods.sort)
    end
  end

  def test_allowed_methods_should_be_propagated_to_subclasses
    assert_equal Article::Jail.allowed_methods, Article::ExtendedJail.allowed_methods
  end

  private

  def objects
    [[], {}, 1..2, "a", :a, Time.now, 1, 1.0, nil, false, true]
  end

  def reject_pretty_methods(methods)
    methods.reject{ |method| method =~ /^pretty_/ }
  end

end
