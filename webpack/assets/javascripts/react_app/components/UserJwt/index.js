import React from 'react';
import { useDispatch, useSelector } from 'react-redux';

import { post } from '../../redux/API';
import {
  selectAPIByKey,
  selectAPIResponse,
} from '../../redux/API/APISelectors';
import { foremanUrl } from '../../../foreman_tools';

import { USER_JWT } from './UserJwtConstants';
import UserJwtForm from './components/UserJwtForm';
import UserJwtField from './components/UserJwtField';
import './UserJwt.scss';

const UserJwt = () => {
  const dispatch = useDispatch();
  const apiStatus = useSelector(
    state => selectAPIByKey(state, USER_JWT).status || null
  );
  const token = useSelector(
    state => selectAPIResponse(state, USER_JWT).jwt || null
  );

  const handleSubmit = (expirationUnit, expirationValue) => {
    dispatch(
      post({
        key: USER_JWT,
        url: foremanUrl('/users/jwt'),
        params: {
          expiration_unit: expirationUnit.value,
          expiration_value: expirationValue,
        },
      })
    );
  };

  return (
    <React.Fragment>
      <UserJwtForm handleSubmit={handleSubmit} />
      <UserJwtField apiStatus={apiStatus} token={token} />
    </React.Fragment>
  );
};

export default UserJwt;
