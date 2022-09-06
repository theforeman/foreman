import PropTypes from 'prop-types';
import React, { useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { selectAllSortedStatuses } from './HostStatusSelector';
import { foremanUrl } from '../../../common/helpers';
import StatusesModal from './StatusesModal';
import StatusIcon from './StatusIcon';
import { HOST_STATUSES_KEY } from './Constants';
import { APIActions } from '../../../redux/API';
import { selectAPIResponse } from '../../../redux/API/APISelectors';

const GlobalStatus = ({ hostName, canForgetStatuses }) => {
  const [modalStatus, setModalStatus] = useState(false);
  const dispatch = useDispatch();

  const { global } = useSelector(state =>
    selectAPIResponse(state, HOST_STATUSES_KEY)
  );
  const url = foremanUrl(`/hosts/${hostName}/statuses`);
  const statuses = useSelector(selectAllSortedStatuses);

  const handleGlobalStatusClick = () => {
    dispatch(
      APIActions.get({
        url,
        key: HOST_STATUSES_KEY,
      })
    );
    setModalStatus(true);
  };

  return (
    <>
      <a style={{ fontSize: '18px' }} onClick={handleGlobalStatusClick}>
        <StatusIcon statusNumber={global} />
      </a>
      <StatusesModal
        statuses={statuses}
        isOpen={modalStatus}
        hostName={hostName}
        onClose={() => {
          setModalStatus(false);
        }}
        canForgetStatuses={canForgetStatuses}
      />
    </>
  );
};

GlobalStatus.propTypes = {
  hostName: PropTypes.string.isRequired,
  canForgetStatuses: PropTypes.bool.isRequired,
};

export default GlobalStatus;
