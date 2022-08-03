require 'test_helper'

class StorageTest < ActiveSupport::TestCase
  setup do
    Foreman::SelectableColumns::Storage.stubs(tables: HashWithIndifferentAccess.new)
  end

  test 'should store table definitions' do
    Foreman::SelectableColumns::Storage.define(:default) do
      category(:general) {}
    end
    Foreman::SelectableColumns::Storage.define(:nondefault) do
      category(:nongeneral) {}
    end

    assert_not_empty Foreman::SelectableColumns::Storage.tables
  end

  test 'should not re-define a table' do
    only_name = 'general'
    Foreman::SelectableColumns::Storage.define(:default) do
      category(only_name) {}
    end
    Foreman::SelectableColumns::Storage.define(:default) do
      category(:general2) {}
    end
    table = Foreman::SelectableColumns::Storage.tables[:default]

    assert_equal 1, table.size
    assert_equal only_name, table.first.id
  end

  test 'should re-use defined table' do
    Foreman::SelectableColumns::Storage.define(:default) do
      category(:general) {}
    end
    Foreman::SelectableColumns::Storage.register(:default) do
      category(:nongeneral) {}
    end
    table = Foreman::SelectableColumns::Storage.tables[:default]

    assert_equal 2, table.size
  end

  test 'should not define a table while registering categories' do
    Foreman::SelectableColumns::Storage.register(:default) do
      category(:nongeneral) {}
    end

    assert_empty Foreman::SelectableColumns::Storage.tables
  end

  test 'should return defined columns on a table in simplified form' do
    expected = [
      {
        id: 'general',
        name: 'General',
        columns: [
          { id: 'key1', name: 'Key1' },
          { id: 'key2', name: 'Key2' },
        ],
      },
      {
        id: 'nongeneral',
        name: 'Nongeneral',
        columns: [
          { id: 'key3', name: 'Key3' },
          { id: 'key1', name: 'Key1' },
        ],
      },
    ]

    Foreman::SelectableColumns::Storage.define(:default) do
      category :general do
        column :key1, th: { label: 'Key1' }, td: {}
        column :key2, th: { label: 'Key2' }, td: {}
      end
      category :nongeneral, label: 'Nongeneral' do
        column :key3, th: { label: 'Key3' }, td: {}
        use_column :key1, from: :general
      end
    end

    result = Foreman::SelectableColumns::Storage.defined_for(:default)
    assert_equal expected, result
  end

  test 'should return filtered by preferences full definitions of columns' do
    Foreman::SelectableColumns::Storage.define(:default) do
      category :general do
        column :key1, th: { label: 'Key1' }, td: {}
        column :key2, th: { label: 'Key2' }, td: {}
      end
      category :nongeneral, label: 'Nongeneral' do
        column :key3, th: { label: 'Key3' }, td: {}
        use_column :key1, from: :general
      end
    end

    expected = [
      { key: 'key1', th: { label: 'Key1' }, td: {} }.with_indifferent_access,
      { key: 'key3', th: { label: 'Key3' }, td: {} }.with_indifferent_access,
    ]

    user = FactoryBot.create(:user)
    user.table_preferences.create(name: 'default', columns: ['key1', 'key3'])

    result = Foreman::SelectableColumns::Storage.selected_by(user, :default)

    assert_equal expected, result
  end

  test 'should return default category if user does not have preferences' do
    Foreman::SelectableColumns::Storage.define(:default) do
      category :general, default: true do
        column :key1, th: { label: 'Key1' }, td: {}
        column :key2, th: { label: 'Key2' }, td: {}
      end
      category :nongeneral, label: 'Nongeneral' do
        column :key3, th: { label: 'Key3' }, td: {}
        use_column :key1, from: :general
      end
    end

    expected = [
      { key: 'key1', th: { label: 'Key1' }, td: {} }.with_indifferent_access,
      { key: 'key2', th: { label: 'Key2' }, td: {} }.with_indifferent_access,
    ]

    user = FactoryBot.create(:user)

    result = Foreman::SelectableColumns::Storage.selected_by(user, :default)

    assert_equal expected, result
  end
end
