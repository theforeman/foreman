import React from 'react';
import PropTypes from 'prop-types';

import {
  FormGroup,
  FormSelect,
  FormSelectOption,
} from '@patternfly/react-core';

import { translate as __ } from '../../../../../common/I18n';

export const DownloadUtilities = ['curl', 'wget'];
const DownloadUtility = ({
  downloadUtility,
  handleDownloadUtility,
  isLoading,
}) => (
  <FormGroup label={__('Download utility')} fieldId="reg_download_utility">
    <FormSelect
      ouiaId="reg_download_utility"
      value={downloadUtility}
      onChange={v => handleDownloadUtility(v)}
      className="without_select2"
      id="reg_download_utility"
      isDisabled={isLoading}
    >
      {DownloadUtilities.map(item => (
        <FormSelectOption key={item} value={item} label={item} />
      ))}
    </FormSelect>
  </FormGroup>
);

DownloadUtility.propTypes = {
  downloadUtility: PropTypes.oneOf(DownloadUtilities),
  handleDownloadUtility: PropTypes.func.isRequired,
  isLoading: PropTypes.bool.isRequired,
};

DownloadUtility.defaultProps = {
  downloadUtility: DownloadUtilities[0],
};

export default DownloadUtility;
