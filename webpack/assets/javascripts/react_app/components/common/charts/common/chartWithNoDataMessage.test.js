import React from 'react';
import { mount } from 'enzyme';
import toJson from 'enzyme-to-json';

import { chartWithNoDataMessage } from './chartWithNoDataMessage';

describe('common chart components', () => {
  const Chart = chartWithNoDataMessage(() => <h1>Chart</h1>);
  it('render a messagebox if no data', () => {
    [undefined, null, {}, { data: {} }, { data: { columns: [] } }]
      .forEach(props => expect(toJson(mount(<Chart {...props} />))).toMatchSnapshot());
  });
  it('render chart if there is data', () => {
    expect(toJson(mount(<Chart
      data={{ columns: [['time', 1, 2], ['data', 0, 20]] }} />))).toMatchSnapshot();
  });
});
