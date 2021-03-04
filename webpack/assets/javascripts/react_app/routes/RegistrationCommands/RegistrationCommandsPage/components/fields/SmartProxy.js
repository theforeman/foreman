import React from 'react';
import PropTypes from 'prop-types';

import {
  FormGroup,
  FormSelect,
  FormSelectOption,
} from '@patternfly/react-core';

import LabelIcon from '../../../../../components/common/LabelIcon';

import { translate as __ } from '../../../../../common/I18n';
import { emptyOption } from '../../RegistrationCommandsPageHelpers';

const SmartProxy = ({
  smartProxyId,
  smartProxies,
  handleSmartProxy,
  isLoading,
}) => (
  <FormGroup
    label={__('Smart Proxy')}
    fieldId="reg_smart_proxy"
    labelIcon={
      <LabelIcon
        text={__(
          'Only Smart Proxies with Registration feature enabled are displayed.'
        )}
      />
    }
  >
    <FormSelect
      value={smartProxyId}
      onChange={v => handleSmartProxy(v)}
      className="without_select2"
      id="reg_smart_proxy_select"
      isDisabled={isLoading || smartProxies.length === 0}
    >
      {emptyOption(smartProxies.length)}
      {smartProxies.map((sp, i) => (
        <FormSelectOption key={i} value={sp.id} label={sp.name} />
      ))}
    </FormSelect>
  </FormGroup>
);

SmartProxy.propTypes = {
  smartProxyId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
  handleSmartProxy: PropTypes.func.isRequired,
  isLoading: PropTypes.bool.isRequired,
  smartProxies: PropTypes.array,
};

SmartProxy.defaultProps = {
  smartProxyId: '',
  smartProxies: [],
};

export default SmartProxy;
