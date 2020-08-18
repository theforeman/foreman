import React from 'react';
import NewModelPage from './NewModelPage';

import { useForemanContext } from '../../../Root/Context/ForemanContext';

import PermissionDenied from '../../../components/PermissionDenied';

import { MODELS_PATH, CREATE_PERMISSION } from '../constants';

const userAllowed = (user, permission) => user.admin || user.permissions.find(item => item.name === permission);

const WrappedNewModelPage = props => {
  const { currentUser } = useForemanContext();

  if (userAllowed(currentUser, CREATE_PERMISSION)) {
    return (
      <NewModelPage {...props} />
    )
  }
  return (
    <PermissionDenied missingPermissions={[CREATE_PERMISSION]} />
  )
}

export default WrappedNewModelPage;
