import React, { useState } from 'react';
import { useSelector, useDispatch } from 'react-redux';
import { useForemanUser } from '../../Root/Context/ForemanContext';
import { invalidateJwtAction } from './InvalidateUserJwtActions';
import { selectStatus } from './InvalidateUserJwtSelectors';
import { STATUS } from '../../constants';

import InvalidateUserJwt from './InvalidateUserJwt';

const InvalidateUserJwtWrapper = () => {
  const dispatch = useDispatch();
  const { id } = useForemanUser();
  const apiStatus = useSelector(selectStatus);

  const isLoading = apiStatus === STATUS.PENDING;
  const [isModalOpen, setIsModalOpen] = useState(false);

  const invalidateJWT = () => {
    setIsModalOpen(false);
    dispatch(invalidateJwtAction(id));
  };

  return (
    <InvalidateUserJwt
      isModalOpen={isModalOpen}
      handleModal={setIsModalOpen}
      handleSubmit={invalidateJWT}
      apiStatus={apiStatus}
      isLoading={isLoading}
    />
  );
};

export default InvalidateUserJwtWrapper;
