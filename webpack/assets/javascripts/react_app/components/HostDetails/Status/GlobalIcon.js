import PropTypes from 'prop-types';
import React, { useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { selectAllSortedStatuses } from './HostStatusSelector';
import { useAPI } from '../../../common/hooks/API/APIHooks';
import { foremanUrl } from '../../../common/helpers';
import StatusesModal from './StatusesModal';
import StatusIcon from './StatusIcon';
import { getStatuses } from './StatusActions';
import { HOST_STATUSES_OPTIONS } from './Constants';

const AggregateStatus = ({ hostName }) => {
  const [modalStatus, setModalStatus] = useState(false);
  const dispatch = useDispatch();

  const url = hostName && foremanUrl(`/hosts/${hostName}/statuses`);
  const {
    response: { global },
  } = useAPI('get', url, HOST_STATUSES_OPTIONS);

  const handleGlobalStatusClick = () => {
    if (hostName) {
      dispatch(getStatuses(hostName));
      setModalStatus(true);
    }
  };
  const statuses = useSelector(selectAllSortedStatuses);

  return (
    <>
      <a onClick={handleGlobalStatusClick}>
        <StatusIcon statusNumber={global} />
      </a>
      <StatusesModal
        statuses={statuses}
        isOpen={modalStatus}
        hostName={hostName}
        onClose={() => {
          setModalStatus(false);
        }}
      />
    </>
  );
};

AggregateStatus.propTypes = {
  hostName: PropTypes.string,
};

AggregateStatus.defaultProps = {
  hostName: undefined,
};

export default AggregateStatus;
