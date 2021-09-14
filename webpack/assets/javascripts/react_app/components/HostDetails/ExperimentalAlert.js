import PropTypes from 'prop-types';
import React, { useState } from 'react';
import {
  Alert,
  AlertActionCloseButton,
  AlertActionLink,
} from '@patternfly/react-core';
import { translate as __ } from '../../common/I18n';
import { visit } from '../../../foreman_navigation';
import { foremanUrl } from '../../common/helpers';
import { LEGACY_DETAILS_PATH } from './consts';

const ExperimentalAlert = ({ hostId }) => {
  const [alertVisibility, setAlertVisibility] = useState(true);
  if (!alertVisibility) return null;
  return (
    <Alert
      isInline
      variant="info"
      title={__(
        'This page redesign is experimental and under active development.'
      )}
      actionClose={
        <AlertActionCloseButton onClose={() => setAlertVisibility(false)} />
      }
      actionLinks={
        <>
          <AlertActionLink
            onClick={() =>
              window.open(
                'https://community.theforeman.org/t/foreman-3-0-new-host-detail-page-feedback/25281',
                '_blank'
              )
            }
          >
            {__('Share your feedback')}
          </AlertActionLink>
          <AlertActionLink
            onClick={() =>
              visit(foremanUrl(`${LEGACY_DETAILS_PATH}/${hostId}`))
            }
          >
            {__('Switch to previous UI')}
          </AlertActionLink>
        </>
      }
    />
  );
};

ExperimentalAlert.propTypes = {
  hostId: PropTypes.string,
};
ExperimentalAlert.defaultProps = {
  hostId: undefined,
};

export default ExperimentalAlert;
