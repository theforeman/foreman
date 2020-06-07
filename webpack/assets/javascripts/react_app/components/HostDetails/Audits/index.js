import React from 'react';
import { Card, CardBody } from '@patternfly/react-core';
import styles from '@patternfly/react-styles/css/components/DataList/data-list';
import { translate as __ } from '../../../common/I18n';

const AuditCard = ({ audits }) => {
  return (
    <Card isHoverable>
      <CardBody>{__('Audits')}</CardBody>
    </Card>
  );
};

export default AuditCard;
