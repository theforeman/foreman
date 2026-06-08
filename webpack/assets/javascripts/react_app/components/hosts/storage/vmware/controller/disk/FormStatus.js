import React from 'react';
import PropTypes from 'prop-types';
import { Spinner, Popover, Button } from '@patternfly/react-core';
import { ExclamationCircleIcon } from '@patternfly/react-icons';
import { STATUS } from '../../../../../../constants';
import { translate as __ } from '../../../../../../../react_app/common/I18n';

const FormStatus = ({ status, errorMessage, fieldName }) => {
  switch (status) {
    case STATUS.PENDING: {
      return <Spinner isInline />;
    }
    case STATUS.ERROR: {
      return (
        <Popover
          aria-label={`error popover for ${fieldName}`}
          bodyContent={errorMessage}
        >
          <Button
            variant="control"
            aria-label={`popover for ${fieldName}`}
            ouiaId={`error-popover-button-${fieldName}`}
          >
            <ExclamationCircleIcon />
          </Button>
        </Popover>
      );
    }
    default: {
      return null;
    }
  }
};

FormStatus.propTypes = {
  status: PropTypes.string,
  errorMessage: PropTypes.string,
  fieldName: PropTypes.string,
};

FormStatus.defaultProps = {
  status: STATUS.ERROR,
  errorMessage: __('An error occurred loading the data.'),
  fieldName: '',
};

export default FormStatus;
