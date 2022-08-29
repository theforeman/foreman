import PropTypes from 'prop-types';
import React, { useState } from 'react';
import { useSelector } from 'react-redux';
import {
  Card,
  CardTitle,
  CardBody,
  CardFooter,
  Bullseye,
  GridItem,
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
import GlobalState from './GlobalState';
import AggregateStatusItem from './AggregateStatusItem';
import { translate as __ } from '../../../common/I18n';
import StatusIcon from './StatusIcon';
import {
  HOST_STATUSES_OPTIONS,
  OK_STATUS_STATE,
  WARNING_STATUS_STATE,
  ERROR_STATUS_STATE,
  NA_STATUS_STATE,
  SUPPORTED_STATUSES,
} from './Constants';
import './styles.scss';

const AggregateStatusCard = ({
  hostName,
  hostDetails: {
    permissions: {
      view_hosts: canViewStatuses,
      forget_status_hosts: canForgetStatuses,
    } = {},
  },
}) => {
  const [openModal, setOpenModal] = useState(false);
  const [chosenType, setChosenType] = useState();

  const url = foremanUrl(`/hosts/${hostName}/statuses`);
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

  const isOKState =
    responseStatus === STATUS.RESOLVED &&
    warnStatus.length === 0 &&
    errorStatus.length === 0;

  const hadleIconClick = type => {
    setChosenType(type);
    setOpenModal(true);
  };

  return (
    <GridItem xl2={3} xl={4} md={6} lg={4}>
      <Card className="card-pf-aggregate-status">
        <CardTitle>
          <span>
            <span style={{ marginRight: '0.5rem' }}>{__('Host status')}</span>
            {!isOKState && (
              <StatusIcon
                statusNumber={global}
                style={{ position: 'relative', top: '2px' }}
              />
            )}
          </span>
        </CardTitle>
        <CardBody style={{ height: '129px' }}>
          <GlobalState
            cannotViewStatuses={!canViewStatuses}
            isOKState={isOKState}
            responseStatus={responseStatus}
          >
            <Bullseye>
              <span className="card-pf-aggregate-status-notifications">
                {SUPPORTED_STATUSES.map(({ label, status }) => (
                  <AggregateStatusItem
                    key={`status-${label}`}
                    label={label}
                    responseStatus={responseStatus}
                    status={status}
                    onClick={() => hadleIconClick(status)}
                    amount={statusesMapper(status).length}
                  />
                ))}
              </span>
            </Bullseye>
          </GlobalState>
        </CardBody>
        <CardFooter>
          <a
            onClick={() => {
              setChosenType(undefined);
              setOpenModal(true);
            }}
          >
            {__('Manage all statuses')}
          </a>
        </CardFooter>
      </Card>
      <StatusesModal
        canForgetStatuses={canForgetStatuses}
        type={chosenType}
        statuses={statusesMapper(chosenType)}
        hostName={hostName}
        isOpen={openModal}
        onClose={() => {
          setOpenModal(false);
        }}
      />
    </GridItem>
  );
};

AggregateStatusCard.propTypes = {
  hostName: PropTypes.string,
  hostDetails: PropTypes.shape({
    permissions: PropTypes.shape({
      view_hosts: PropTypes.bool,
      forget_status_hosts: PropTypes.bool,
    }),
  }),
};

AggregateStatusCard.defaultProps = {
  hostName: undefined,
  hostDetails: {
    permissions: { statuses_hosts: false, forget_status_hosts: false },
  },
};

export default AggregateStatusCard;
