import React from 'react';
import PropTypes from 'prop-types';

import {
  FormGroup,
  FormSelect,
  FormSelectOption,
  FormHelperText,
  HelperText,
  HelperTextItem,
} from '@patternfly/react-core';

import LabelIcon from '../../../../../components/common/LabelIcon';

import { translate as __ } from '../../../../../common/I18n';
import { emptyOption } from '../../RegistrationCommandsPageHelpers';

const SmartProxy = ({
  smartProxyId,
  smartProxies,
  handleSmartProxy,
  isLoading,
}) => {
  const smartProxyUrl = () => {
    if (!smartProxyId) return '';

    const proxy = smartProxies.filter(p => `${p.id}` === smartProxyId)[0];
    return proxy?.url;
  };

  return (
    <FormGroup
      label={__('Smart proxy')}
      fieldId="reg_smart_proxy"
      labelIcon={
        <LabelIcon
          text={__(
            'Only smart proxies with enabled `Templates` and `Registration` features are displayed.'
          )}
        />
      }
    >
      <FormSelect
        ouiaId="reg_smart_proxy"
        value={smartProxyId}
        onChange={(_event, v) => handleSmartProxy(v)}
        className="without_select2"
        id="reg_smart_proxy"
        isDisabled={isLoading || smartProxies.length === 0}
      >
        {emptyOption(smartProxies.length)}
        {smartProxies.map((sp, i) => (
          <FormSelectOption key={i} value={sp.id} label={sp.name} />
        ))}
      </FormSelect>
      <FormHelperText>
        <HelperText>
          <HelperTextItem>{smartProxyUrl()}</HelperTextItem>
        </HelperText>
      </FormHelperText>
    </FormGroup>
  );
};

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
