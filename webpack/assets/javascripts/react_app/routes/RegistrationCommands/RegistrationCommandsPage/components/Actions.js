import React from 'react';
import PropTypes from 'prop-types';
import { Link } from 'react-router-dom';

import { Alert, ActionGroup, Button, FormGroup } from '@patternfly/react-core';

import { sprintf, translate as __ } from '../../../../common/I18n';
import { foremanUrl } from '../../../../../foreman_tools';

const Actions = ({ isLoading, isGenerating, handleSubmit, invalidFields }) => (
  <>
    <FormGroup fieldId="actions_help" className="pf-u-pt-xl">
      {invalidFields.length === 1 && (
        <Alert
          variant="warning"
          title={sprintf('Invalid field: %s', invalidFields[0])}
        />
      )}
      {invalidFields.length > 1 && (
        <Alert
          variant="warning"
          title={sprintf('Invalid fields: %s', invalidFields.join(', '))}
        />
      )}
    </FormGroup>
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
      <Link to={foremanUrl('/hosts')}>
        <Button variant="link">{__('Cancel')}</Button>
      </Link>
    </ActionGroup>
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
