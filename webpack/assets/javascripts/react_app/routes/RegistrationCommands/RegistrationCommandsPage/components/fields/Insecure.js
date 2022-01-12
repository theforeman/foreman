import React from 'react';
import PropTypes from 'prop-types';

import { FormGroup, Checkbox } from '@patternfly/react-core';
import LabelIcon from '../../../../../components/common/LabelIcon';

import { translate as __ } from '../../../../../common/I18n';

const Insecure = ({ insecure, handleInsecure, isLoading }) => (
  <FormGroup fieldId="reg_insecure">
    <Checkbox
      label={
        <span>
          {__('Insecure')}{' '}
          <LabelIcon
            text={__(
              'If the target machine does not trust the host SSL certificate, the initial connection could be subject to a man-in-the-middle attack. If you accept the risk and do not require the server authenticity to be verified, you can enable insecure argument for the initial curl. Note that all subsequent communication is then properly secured, because the initial request deploys the SSL certificate for the rest of the registration process.'
            )}
          />
        </span>
      }
      id="reg_insecure"
      onChange={() => handleInsecure(!insecure)}
      isDisabled={isLoading}
      isChecked={insecure}
    />
  </FormGroup>
);

Insecure.propTypes = {
  insecure: PropTypes.bool.isRequired,
  handleInsecure: PropTypes.func.isRequired,
  isLoading: PropTypes.bool.isRequired,
};

export default Insecure;
