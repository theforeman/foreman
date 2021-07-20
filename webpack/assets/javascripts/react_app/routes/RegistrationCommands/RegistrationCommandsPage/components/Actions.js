import React from 'react';
import PropTypes from 'prop-types';
import { Link } from 'react-router-dom';

import {
  ActionGroup,
  Button,
  FormHelperText,
  FormGroup,
} from '@patternfly/react-core';
import { ExclamationCircleIcon } from '@patternfly/react-icons';

import { sprintf, translate as __ } from '../../../../common/I18n';

const Actions = ({ isLoading, isGenerating, handleSubmit, invalidFields }) => (
  <>
    <ActionGroup>
      <Button
        variant="primary"
        id="generate_btn"
        onClick={e => handleSubmit(e)}
        isDisabled={isLoading || invalidFields.length > 0}
        isLoading={isGenerating}
      >
        {isGenerating ? __('Generating ...') : __('Generate')}
      </Button>

      {/* Can't use <RedirectCancelButton> due to infinitive loop */}
      <Link to="/hosts">
        <Button variant="link">{__('Cancel')}</Button>
      </Link>
    </ActionGroup>
    <FormGroup fieldId="actions_help">
      <FormHelperText
        icon={<ExclamationCircleIcon />}
        isHidden={invalidFields.length === 0}
      >
        {invalidFields.length === 1 &&
          sprintf('Invalid field: %s', invalidFields[0])}
        {invalidFields.length > 1 &&
          sprintf('Invalid fields: %s', invalidFields.join(', '))}
      </FormHelperText>
    </FormGroup>
  </>
);

Actions.propTypes = {
  handleSubmit: PropTypes.func.isRequired,
  isLoading: PropTypes.bool.isRequired,
  isGenerating: PropTypes.bool.isRequired,
  invalidFields: PropTypes.oneOfType([PropTypes.array, PropTypes.object]),
};

Actions.defaultProps = {
  invalidFields: [],
};

export default Actions;
