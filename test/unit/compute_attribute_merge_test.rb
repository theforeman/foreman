require 'test_helper'

class ComputeAttributeMergeTest < ActiveSupport::TestCase
  def setup
    @merge = ComputeAttributeMerge.new
    @profile_attributes = compute_attributes(:two)
    @host = FactoryBot.build_stubbed(:host)
  end

  test "it doesn't change anything when profile attributes are nil" do
    @host.compute_attributes = { 'cpus' => 1 }
    @merge.run(@host, nil)

    assert_equal({ 'cpus' => 1 }, @host.compute_attributes)
  end

  test "it sets the profile attributes when host attributes are nil" do
    @profile_attributes.stubs(:vm_attrs).returns(
      {
        'cpus' => 1,
        'memory' => 4294967296,
      }
    )
    @merge.run(@host, @profile_attributes)

    assert_equal({ 'cpus' => 1, 'memory' => 4294967296 }, @host.compute_attributes)
  end

  test "it merges first level attributes" do
    @profile_attributes.stubs(:vm_attrs).returns(
      {
        'cpus' => 1,
        'memory' => 4294967296,
      }
    )
    @host.compute_attributes = {
      'cpus' => 2,
    }

    @merge.run(@host, @profile_attributes)

    assert_equal({ 'cpus' => 2, 'memory' => 4294967296 }, @host.compute_attributes)
  end

  test "it merges volume_attributes" do
    @profile_attributes.stubs(:vm_attrs).returns(
      {
        'cpus' => 1,
        'memory' => 4294967296,
        'volumes_attributes' => {
          '0' => {
            'attr0a' => 'a',
            'attr0b' => 'b',
          },
          '1' => {
            'attr0a' => 'a',
            'attr0b' => 'b',
          },
        },
      })
    @host.compute_attributes = {
      'cpus' => 2,
      'volumes_attributes' => {
        '1' => {
          'attr0b' => 'b1',
          'attr0c' => 'c1',
        },
      },
    }
    expected_attrs = {
      'cpus' => 2,
      'memory' => 4294967296,
      'volumes_attributes' => {
        '0' => {
          'attr0a' => 'a',
          'attr0b' => 'b',
        },
        '1' => {
          'attr0a' => 'a',
          'attr0b' => 'b1',
          'attr0c' => 'c1',
        },
      },
    }

    @merge.run(@host, @profile_attributes)

    assert_equal(expected_attrs, @host.compute_attributes)
  end

  test "it does not merge interfaces / nics_attributes" do
    @profile_attributes.compute_resource.expects(:interfaces_attrs_name).returns(:nics)

    @profile_attributes.stubs(:vm_attrs).returns(
      {
        'cpus' => 1,
        'memory' => 4294967296,
        'nics_attributes' => {
          '0' => {
            'attr0a' => 'a',
            'attr0b' => 'b',
          },
        },
      }
    )
    @host.compute_attributes = {
      'cpus' => 2,
    }
    expected_attrs = {
      'cpus' => 2,
      'memory' => 4294967296,
    }

    @merge.run(@host, @profile_attributes)

    assert_equal(expected_attrs, @host.compute_attributes)
  end
end
