import React from 'react';
import { Button, Spinner } from '@patternfly/react-core';
import PropTypes from 'prop-types';
import { translate as __ } from '../../../../common/I18n';

const SubmitBtn = ({ isSubmitting, onSubmit, variant, btnText }) => (
  <Button
    ouiaId="submit-button"
    variant={variant}
    isDisabled={isSubmitting}
    onClick={onSubmit}
  >
    &nbsp;
    {btnText}
    &nbsp;
    {isSubmitting && (
      <span className="fr">
        <Spinner size="sm" aria-label="Loading" isInline />
      </span>
    )}
  </Button>
);

SubmitBtn.propTypes = {
  isSubmitting: PropTypes.bool.isRequired,
  onSubmit: PropTypes.func.isRequired,
  variant: PropTypes.oneOf(['primary']),
  btnText: PropTypes.string,
};

SubmitBtn.defaultProps = {
  variant: 'primary',
  btnText: __('Submit'),
};

export default SubmitBtn;
