import React from 'react';
import { shallow } from '@theforeman/test';
import ModalProgressBar from '../ModalProgressBar';

describe('ModalProgressBar', () => {
  const props = {
    show: true,
    title: 'Refresh Manifest',
    progress: 9,
  };
  const message = 'Proceed with this action?';

  it('renders a modal progress bar', async () => {
    const dialog = shallow(<ModalProgressBar {...props} {...{ message }} />);
    expect(dialog).toMatchSnapshot();
  });
});
