import React from 'react';
import { mount, shallow } from '@theforeman/test';
import ModelsTable from './ModelsTable';
import { Table } from '../common/table';
import MessageBox from '../common/MessageBox';

const results = [
  {
    info: null,
    created_at: '2018-03-26 09:54:21 +0300',
    updated_at: '2018-03-26 09:54:21 +0300',
    vendor_class: null,
    hardware_model: null,
    id: 29,
    name: 'X8SIL',
    can_edit: true,
    can_delete: true,
    hosts_count: 1,
  },
];

describe('ModelsTable', () => {
  it('render table on sucess', () => {
    const getModelItems = jest.fn().mockReturnValue([]);
    const view = mount(
      <ModelsTable results={results} getTableItems={getModelItems} />
    );
    expect(getModelItems.mock.calls).toHaveLength(1);
    expect(view.find(Table)).toHaveLength(1);
  });

  it('render error message box on failure', () => {
    const view = shallow(
      <ModelsTable
        getTableItems={jest.fn(() => [])}
        results={[{}]}
        error={Error('some error message')}
        status="ERROR"
      />
    );
    expect(view.find(MessageBox)).toHaveLength(1);
  });
});
