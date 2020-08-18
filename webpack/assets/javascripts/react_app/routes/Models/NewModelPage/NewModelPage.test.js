import React from 'react';

import { renderWithRedux } from '../../../rtlWrapper';

import NewModelPage from './index';

describe('NewModelPage', () => {
  it('should handle submit', () => {
    const res = renderWithRedux(<NewModelPage />)
    const crumb = res.getByText('Create Hardware Model')
    expect(crumb).toBeInTheDocument();
  });
});
