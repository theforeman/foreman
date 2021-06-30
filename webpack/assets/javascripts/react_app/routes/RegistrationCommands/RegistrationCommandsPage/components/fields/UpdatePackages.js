import React from 'react';
import PropTypes from 'prop-types';

import { FormGroup, Checkbox } from '@patternfly/react-core';
import LabelIcon from '../../../../../components/common/LabelIcon';

import { translate as __ } from '../../../../../common/I18n';

const UpdatePackages = ({
  updatePackages,
  handleUpdatePackages,
  isLoading,
}) => (
  <FormGroup fieldId="reg_update_packages">
    <Checkbox
      label={
        <span>
          {__('Update packages')}{' '}
          <LabelIcon text={__('Update all packages on the host')} />
        </span>
      }
      id="reg_update_packages"
      onChange={() => handleUpdatePackages(!updatePackages)}
      isDisabled={isLoading}
      isChecked={updatePackages}
    />
  </FormGroup>
);

UpdatePackages.propTypes = {
  updatePackages: PropTypes.bool.isRequired,
  handleUpdatePackages: PropTypes.func.isRequired,
  isLoading: PropTypes.bool.isRequired,
};

export default UpdatePackages;
