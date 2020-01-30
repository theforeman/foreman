import React from 'react';

import { useDispatch, useSelector } from 'react-redux';

import { useForemanContext } from '../../../../../Root/Context/ForemanContext';

import TestEmail from './TestEmail';

import { selectTestEmailLoading } from './TestEmailSelectors';

import { testEmail } from './TestEmailActions';

const WrappedTestEmail = props => {
  const loading = useSelector(state => selectTestEmailLoading(state));

  const dispatch = useDispatch();

  const { currentUser } = useForemanContext();
  const currentUserId = currentUser && currentUser.id;

  return currentUserId ? (
    <TestEmail
      loading={loading}
      testEmail={() => dispatch(testEmail(currentUserId))}
    />
  ) : null;
};

export default WrappedTestEmail;
