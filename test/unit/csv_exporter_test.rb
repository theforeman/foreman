require 'test_helper'

class CsvExporterTest < ActiveSupport::TestCase
  test 'return correct amount of lines' do
    result = CsvExporter.export(Host::Managed, [:id])
    assert_equal "Id\n", result.next
    assert_equal result.count, Host::Managed.count+1
  end

  test 'handles empty results correctly' do
    result = CsvExporter.export(Host::Managed.where(:name => 'no-such-host'), [:id, :name])
    assert_equal "Id,Name\n", result.next
    assert_equal 1, result.count
    assert_raises StopIteration do
      result.next
    end
  end

  test 'calls methods on records' do
    id = Domain.first.id
    Domain.any_instance.expects(:test_method).once.returns('success!')
    result = CsvExporter.export(Domain.where(:id => id), [:id, :test_method])
    assert_equal "Id,Test Method\n", result.next
    assert_equal "#{id},success!\n", result.next
    assert_raises StopIteration do
      result.next
    end
  end
end
