import React from 'react';
import PropTypes from 'prop-types';

import {
  Alert,
  FormGroup,
  ClipboardCopy,
  ClipboardCopyVariant,
} from '@patternfly/react-core';
import { translate as __ } from '../../../../common/I18n';
import { STATUS } from '../../../../constants';

const Command = ({ apiStatus, command }) => {
  switch (apiStatus) {
    case STATUS.ERROR:
      return (
        <Alert
          variant="danger"
          title={__(
            'There was an error while generating the command, see the logs for more information.'
          )}
        />
      );
    case STATUS.RESOLVED:
      return (
        <FormGroup label={__('Registration command')}>
          <ClipboardCopy
            variant={ClipboardCopyVariant.expansion}
            isReadOnly
            isCode
            isExpanded
          >
            {command}
          </ClipboardCopy>
        </FormGroup>
      );
    default:
      return <FormGroup />;
  }
};

Command.propTypes = {
  apiStatus: PropTypes.string,
  command: PropTypes.string,
};

Command.defaultProps = {
  apiStatus: undefined,
  command: '',
};

export default Command;
