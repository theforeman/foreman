require 'test_helper'

class CsvExporterTest < ActiveSupport::TestCase
  test 'return correct amount of lines' do
    result = CsvExporter.export(Host::Managed, [:id])
    assert_equal "Id\n", result.next
    assert_equal result.count, Host::Managed.count + 1
    assert_difference('CsvExporter.export(Host::Managed, [:id]).count') do
      FactoryBot.create(:host)
    end
  end

  # Can't do this at the moment, since nil limit doesn't play well with will_paginate
  # test 'ignore pagination' do
  #   FactoryBot.create_list(:domain, 10)
  #   result = CsvExporter.export(Domain.all.paginate(per_page: 5, page:1), [:id])
  #   assert result.count > 5
  # end

  test 'ignore limit' do
    FactoryBot.create_list(:domain, 10)
    result = CsvExporter.export(Domain.all.limit(5), [:id])
    assert result.count > 5
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

  test 'calls nested methods on records' do
    host = FactoryBot.create(:host)
    result = CsvExporter.export(Host::Managed, [:name, 'location.name'])
    assert_equal "Name,Location.Name\n", result.next
    assert_equal "#{host.name},#{host.location.name}\n", result.next
    assert_raises StopIteration do
      result.next
    end
  end

  test 'accepts custom column headers' do
    result = CsvExporter.export(Host::Managed, [:id], ['My Lovely Header'])
    assert_equal "My Lovely Header\n", result.next
  end

  test 'ensures correct number of headers' do
    assert_raises ArgumentError do
      CsvExporter.export(Host::Managed, [:id, :name], ['Not Enough Headers!'])
    end
  end
end
