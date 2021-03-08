import React from 'react';
import RenderingStatusPage from './RenderingStatusPage';
import { RENDERING_STATUS_PATH } from './constants';

export default {
  path: RENDERING_STATUS_PATH,
  render: props => <RenderingStatusPage {...props} />,
};
