import React from 'react';
import AuditsPage from './AuditsPage';
import { AUDITS_PATH } from './constants';

export default {
  path: AUDITS_PATH,
  render: (props) => <AuditsPage {...props} />,
};
