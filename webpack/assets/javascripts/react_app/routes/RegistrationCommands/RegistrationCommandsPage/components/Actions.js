import React from 'react';
import PropTypes from 'prop-types';
import { Link } from 'react-router-dom';

import { ActionGroup, Button } from '@patternfly/react-core';

import { translate as __ } from '../../../../common/I18n';
import { foremanUrl } from '../../../../../foreman_tools';

const Actions = ({ isLoading, isGenerating, handleSubmit, invalidFields }) => (
  <>
    <ActionGroup style={{ marginTop: '50px' }}>
      <Button
        ouiaId="registration_generate_btn"
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
        <Button ouiaId="registration-cancel-button" variant="link">
          {__('Cancel')}
        </Button>
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
