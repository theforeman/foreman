import React from 'react';
import { mount, shallow } from '@theforeman/test';
import ModelsTable from './ModelsTable';
import { Table } from '../common/table';
import MessageBox from '../common/MessageBox';

const results = [
  {
    created_at: '2018-03-26 09:54:21 +0300',
    updated_at: '2018-03-26 09:54:21 +0300',
    snippet: true,
    locked: true,
    id: 29,
    name: 'Report Template',
    can_edit: true,
    can_delete: true,
  },
];

describe('ReportTemplatesTable', () => {
  it('render table on sucess', () => {
    const getTemplateItems = jest.fn().mockReturnValue([]);
    const view = mount(
      <ReportTemplatesTable results={results} getTableItems={getTemplateItems} />
    );
    expect(getTemplateItems.mock.calls).toHaveLength(1);
    expect(view.find(Table)).toHaveLength(1);
  });

  it('render error message box on failure', () => {
    const view = shallow(
      <ReportTemplatesTable
        getTableItems={jest.fn(() => [])}
        results={[{}]}
        error={Error('some error message')}
        status="ERROR"
      />
    );
    expect(view.find(MessageBox)).toHaveLength(1);
  });
});
