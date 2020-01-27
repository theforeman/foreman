import React from 'react';
import { IntegrationTestHelper } from '@theforeman/test';
import InnerHTML from './';
import { reducers } from '../../ReactApp';

const content =
  "<script>tfm.test() </script><div id='test'> <span> Hello World </span> </div> ";

describe('AuditsPage', () => {
  it('rendering', () => {
    const integrationTestHelper = new IntegrationTestHelper(reducers);

    const component = integrationTestHelper.mount(<InnerHTML html={content} />);
    expect(component).toMatchSnapshot();
  });
});
