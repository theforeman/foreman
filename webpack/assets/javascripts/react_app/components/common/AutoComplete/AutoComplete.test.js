import React from 'react';
import { render } from 'enzyme';
import toJson from 'enzyme-to-json';

import AutoComplete, { renderItems } from './index';
import { countItems } from './AutoComplete.fixtures';

describe('Autocomplete component', () => {
  it('should render input but not items on initial render', () => {
    const wrapper = render(<AutoComplete
        items={countItems}
        onInputUpdate={() => {}}
        onSearch={() => {}}
      />);
    expect(toJson(wrapper)).toMatchSnapshot();
  });

  it('renderItems should render the items', () => {
    const wrapper = render(renderItems({ items: countItems, getItemProps: () => {} }));
    expect(toJson(wrapper)).toMatchSnapshot();
  });
});
