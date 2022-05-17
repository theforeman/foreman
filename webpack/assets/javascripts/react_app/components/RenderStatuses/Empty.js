import PropTypes from 'prop-types';
import React from 'react';
import {
  Title,
  EmptyState,
  EmptyStateIcon,
  Spinner,
} from '@patternfly/react-core';
import { BanIcon } from '@patternfly/react-icons';
import { translate as __ } from '../../common/I18n';
import { STATUS } from '../../constants';

const Empty = ({ responseStatus }) => (
  <EmptyState className="pf-u-mt-0" isFullHeight>
    {responseStatus === STATUS.PENDING ? (
      <Spinner isSVG />
    ) : (
      <EmptyStateIcon icon={BanIcon} />
    )}
    <Title size="lg" headingLevel="h4" ouiaId="render-statuses-empty-title">
      {responseStatus === STATUS.PENDING
        ? __('Loading...')
        : __('No statuses to show')}
    </Title>
  </EmptyState>
);

Empty.propTypes = {
  responseStatus: PropTypes.string,
};

Empty.defaultProps = {
  responseStatus: STATUS.PENDING,
};

export default Empty;
