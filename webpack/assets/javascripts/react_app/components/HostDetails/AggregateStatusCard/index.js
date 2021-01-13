import React from 'react';
import { Card, CardTitle, CardBody, Bullseye } from '@patternfly/react-core';
import StatusItem from './StatusItem';
import './styles.css';

const AggregateStatus = ({ global, config, build }) => {
  const isReady = !!global.label;
  return (
    <Card className="card-pf-aggregate-status" isHoverable>
      <CardTitle>
        <span className="fa fa-shield" />{' '}
        <span className="card-pf-aggregate-status-count">Host Status</span>
      </CardTitle>
      <CardBody>
        <Bullseye>
          <p className="card-pf-aggregate-status-notifications">
            <StatusItem
              name="Global"
              status={global.status}
              label={global.label}
              isReady={isReady}
            />
            <StatusItem
              name="Build"
              status={build.status}
              label={build.label}
              isReady={isReady}
            />
            <StatusItem
              name="Config"
              status={config.status}
              label={config.label}
              isReady={isReady}
            />
          </p>
        </Bullseye>
      </CardBody>
    </Card>
  );
};

export default AggregateStatus;
