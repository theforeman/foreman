import PropTypes from 'prop-types';
import React, { useState } from 'react';
import { useSelector } from 'react-redux';
import {
  Card,
  CardTitle,
  CardBody,
  CardFooter,
  Bullseye,
} from '@patternfly/react-core';

import StatusesModal from './StatusesModal';
import { foremanUrl } from '../../../common/helpers';
import { useAPI } from '../../../common/hooks/API/APIHooks';
import { STATUS } from '../../../constants';
import {
  selectErrorStatuses,
  selectWarningStatuses,
  selectOKStatuses,
  selectNAStatuses,
  selectAllSortedStatuses,
} from './HostStatusSelector';
import GlobalOKState from './GlobalOKState';
import AggregateStatusItem from './AggregateStatusItem';
import { translate as __ } from '../../../common/I18n';
import StatusIcon from './StatusIcon';
import {
  HOST_STATUSES_OPTIONS,
  OK_STATUS_STATE,
  WARNING_STATUS_STATE,
  ERROR_STATUS_STATE,
  NA_STATUS_STATE,
} from './Constants';
import './styles.scss';

const AggregateStatusCard = ({ hostName }) => {
  const [openModal, setOpenModal] = useState(false);
  const [chosenType, setChosenType] = useState();

  const url = hostName && foremanUrl(`/hosts/${hostName}/statuses`);
  const {
    response: { global },
    status: responseStatus,
  } = useAPI('get', url, HOST_STATUSES_OPTIONS);

  const okStatuses = useSelector(selectOKStatuses);
  const warnStatus = useSelector(selectWarningStatuses);
  const errorStatus = useSelector(selectErrorStatuses);
  const naStatuses = useSelector(selectNAStatuses);
  const allSortedStatuses = useSelector(selectAllSortedStatuses);

  const statusesMapper = type => {
    switch (type) {
      case OK_STATUS_STATE:
        return okStatuses;
      case WARNING_STATUS_STATE:
        return warnStatus;
      case ERROR_STATUS_STATE:
        return errorStatus;
      case NA_STATUS_STATE:
        return naStatuses;
      default:
        return allSortedStatuses;
    }
  };

  const noErrors =
    responseStatus === STATUS.RESOLVED &&
    warnStatus.length === 0 &&
    errorStatus.length === 0;

  const hadleIconClick = type => {
    setChosenType(type);
    setOpenModal(true);
  };

  return (
    <>
      <Card className="card-pf-aggregate-status" isHoverable>
        <CardTitle>
          <span>
            {__('Host Status')}
            {!noErrors && <StatusIcon statusNumber={global} />}
          </span>
        </CardTitle>
        <CardBody style={{ height: '129px' }}>
          {noErrors ? (
            <GlobalOKState />
          ) : (
            <Bullseye>
              <p className="card-pf-aggregate-status-notifications">
                <AggregateStatusItem
                  label="OK statuses"
                  resonseStatus={responseStatus}
                  status={OK_STATUS_STATE}
                  onClick={() => hadleIconClick(OK_STATUS_STATE)}
                  amount={okStatuses.length}
                />
                <AggregateStatusItem
                  label="Warning statuses"
                  resonseStatus={responseStatus}
                  status={WARNING_STATUS_STATE}
                  onClick={() => hadleIconClick(WARNING_STATUS_STATE)}
                  amount={warnStatus.length}
                />
                <AggregateStatusItem
                  label="Error statuses"
                  resonseStatus={responseStatus}
                  status={ERROR_STATUS_STATE}
                  onClick={() => hadleIconClick(ERROR_STATUS_STATE)}
                  amount={errorStatus.length}
                />
                <AggregateStatusItem
                  label="N/A statuses"
                  resonseStatus={responseStatus}
                  status={NA_STATUS_STATE}
                  onClick={() => hadleIconClick(NA_STATUS_STATE)}
                  amount={naStatuses.length}
                />
              </p>
            </Bullseye>
          )}
        </CardBody>
        <CardFooter>
          <span>
            <a
              onClick={() => {
                setChosenType(undefined);
                setOpenModal(true);
              }}
            >
              {__('Manage all statuses')}
            </a>
          </span>
        </CardFooter>
      </Card>
      <StatusesModal
        type={chosenType}
        statuses={statusesMapper(chosenType)}
        hostName={hostName}
        isOpen={openModal}
        onClose={() => {
          setOpenModal(false);
        }}
      />
    </>
  );
};

AggregateStatusCard.propTypes = {
  hostName: PropTypes.string,
};

AggregateStatusCard.defaultProps = {
  hostName: '',
};

export default AggregateStatusCard;
