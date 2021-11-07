import React from 'react';
import RedirectedEmptyPage from './RedirectedEmptyPage';

const EMPTY_PAGE = '/page-not-found';
export default {
  path: EMPTY_PAGE,
  render: props => <RedirectedEmptyPage {...props} />,
};
