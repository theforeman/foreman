require 'test_helper'

class TemplateTest < ActiveSupport::TestCase
  describe "generating metadata" do
    setup do
      @template = Template.new :name => 'Name of template'
    end

    test "metadata are placed in erb comment" do
      assert_match /\A<%#(\n|.)*%>/, @template.metadata
    end

    test "metadata contains name unchanged" do
      assert_match /^name: Name of template$/, @template.metadata
    end

    test "metadata contains model information" do
      assert_match /^model: Template$/, @template.metadata
    end

    test "metadata skips blank attributes" do
      @template.name = ''
      refute_match /^name:&/, @template.metadata
    end

    test "metadata does not contain dashes prefix" do
      refute_includes @template.metadata, '---'
    end
  end

  describe "stripping metadata" do
    setup do
      content = "<%#
name: basic
%>
few
lines
below"
      @template = Template.new :name => 'basic', :template => content
    end

    test "metadata are stripped from the beginning" do
      without = @template.template_without_metadata
      refute_includes without, '<%#'
    end

    test "silent metadata are stripped too" do
      @template.template.gsub('%>', '-%>')
      without = @template.template_without_metadata
      refute_includes without, '<%#'
    end

    test "metadata are stripped from the middle" do
      @template.template = "<%#\another comment\n%>\nsome\ndata\n" + @template.template
      without = @template.template_without_metadata
      refute_includes without, 'name: basic'
    end

    test "other erb comments not containing name: are preserved" do
      @template.template = "prefix\n<% another erb tag %>\nsome\ndata\n" + @template.template
      without = @template.template_without_metadata
      assert_includes without, "prefix"
      assert_includes without, "<% another erb tag %>"
      assert_includes without, "\nsome\ndata\n"
      assert_includes without, "\nfew\nlines\nbelow"
    end

    test "metadata are detected by name attribute on any comment line" do
      lines = @template.template.lines
      @template.template = [ lines[0], 'another: comment', lines[1..-1] ].flatten.join("\n")
      without = @template.template_without_metadata
      refute_includes without, 'name: basic'
    end
  end

  describe "#filename" do
    setup do
      @template = Template.new
    end

    test "filename adds erb suffix" do
      @template.name = 'a'
      assert_equal 'a.erb', @template.filename
    end

    test "filename replaces spaces to underscores" do
      @template.name = 'a bc d'
      assert_equal 'a_bc_d.erb', @template.filename
    end

    test "filename removes dashes" do
      @template.name = 'a-bc-d'
      assert_equal 'abcd.erb', @template.filename
    end
  end

  describe "#to_erb" do
    setup do
      content = "<%#
name: basic
%>
data"
      @template = Template.new :name => 'basic', :template => content
    end

    test "it generates fresh fresh metadata and replaces original ones" do
      @template.stub(:metadata, "METADATA\n") do
        assert_equal "METADATA\ndata", @template.to_erb
      end
    end

    test "it keeps data that present before original metadata" do
      @template.template = "<?xml ...>\n" + @template.template
      @template.stub(:metadata, "METADATA") do
        assert_equal "<?xml ...>\nMETADATA\ndata", @template.to_erb
      end
    end
  end
end
