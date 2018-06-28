import React from 'react';
import { shallow } from 'enzyme';
import ModelsTable from './ModelsTable';
import { Table } from '../common/table';
import MessageBox from '../common/MessageBox';

const data = {
  pagination: {
    vieType: 'table',
    perPageOptions: [1, 2, 3],
    itemCount: 5,
    perPage: 1,
  },
};

describe('ModelsTable', () => {
  it('render table on sucess', () => {
    const getModelItems = jest.fn().mockReturnValue([]);
    const view = shallow(
      <ModelsTable results={[{}]} getTableItems={getModelItems} data={data} />
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
        data={data}
      />
    );
    expect(view.find(MessageBox)).toHaveLength(1);
  });
});
