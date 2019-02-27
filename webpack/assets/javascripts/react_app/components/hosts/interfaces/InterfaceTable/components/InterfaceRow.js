import UUID from 'uuid/v1';
import React from 'react';
import PropTypes from 'prop-types';
import classNames from 'classnames';
import { OverlayTrigger, Tooltip } from 'patternfly-react';

import {
  translate as __,
  sprintf,
} from '../../../../../../react_app/common/I18n';
import { noop } from '../../../../../common/helpers';
import { fqdn } from '../../../../../../foreman_hosts';

function InterfaceRow(props) {
  const {
    id,
    identifier,
    type,
    typeName,
    primary,
    provision,
    mac,
    ip,
    ip6,
    name,
    domain,
    virtual,
    attachedTo,
    providerSpecificInfo,
    hasErrors,
    removeInterface,
    toggleInterfaceEditing,
    setProvisionInterface,
    setPrimaryInterface,
  } = props;


  const isVirtualType = type => {
    const virtualTypes = ['Nic::Bond', 'Nic::Bridge'];
    return virtualTypes.indexOf(type) >= 0;
  };

  const nicInfo = () => {
    if (virtual || isVirtualType(type)) {
      // common virtual
      if (attachedTo !== '')
        return sprintf(__('virtual attached to %s'), attachedTo);
      return __('virtual');
    }
    return providerSpecificInfo || __('physical');
  }

  const getTooltip = text => <Tooltip id={UUID()}>{text}</Tooltip>;

  return (
    <tr
      id={`interface${id}`}
      className={classNames({ 'has-errors': hasErrors })}
      data-interface-id={id}
    >
      <td className="status hidden-xs" align="center" />
      <td className="flags hidden-xs" align="center">
        <OverlayTrigger
          overlay={getTooltip(__('Primary'))}
          placement="top"
          trigger={['hover', 'focus']}
        >
          <i
            className={classNames('glyphicon glyphicon-tag primary-flag', {
              active: primary,
            })}
            onClick={() => setPrimaryInterface(id)}
          />
        </OverlayTrigger>
        <OverlayTrigger
          overlay={getTooltip(__('Provisioning'))}
          placement="top"
          trigger={['hover', 'focus']}
        >
          <i
            className={classNames('glyphicon glyphicon-hdd provision-flag', {
              active: provision,
            })}
            onClick={() => setProvisionInterface(id)}
          />
        </OverlayTrigger>
      </td>
      <td className="identifier ellipsis">{identifier}</td>
      <td className="type hidden-xs">
        {typeName}
        <div className="additional-info">{nicInfo()}</div>
      </td>
      <td className="mac hidden-xs">{mac}</td>
      <td className="ip hidden-xs">{ip}</td>
      <td className="ip6 hidden-xs">{ip6}</td>
      <td className="fqdn hidden-xs">{fqdn(name, domain)}</td>
      <td>
        <button
          type="button"
          className="btn btn-default"
          onClick={() => toggleInterfaceEditing(id, true)}
        >
          {__('Edit')}
        </button>
        <button
          type="button"
          className="btn btn-danger"
          onClick={() => removeInterface(id)}
          disabled={primary || provision}
        >
          {__('Delete')}
        </button>
      </td>
    </tr>
  );
}

InterfaceRow.propTypes = {
  id: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
  identifier: PropTypes.string,
  type: PropTypes.string,
  typeName: PropTypes.string,
  primary: PropTypes.bool.isRequired,
  provision: PropTypes.bool.isRequired,
  virtual: PropTypes.bool,
  mac: PropTypes.string,
  ip: PropTypes.string,
  ip6: PropTypes.string,
  name: PropTypes.string,
  domain: PropTypes.string,
  attachedTo: PropTypes.string,
  providerSpecificInfo: PropTypes.string,
  hasErrors: PropTypes.bool,
  removeInterface: PropTypes.func,
  toggleInterfaceEditing: PropTypes.func,
  setPrimaryInterface: PropTypes.func,
  setProvisionInterface: PropTypes.func,
};

InterfaceRow.defaultProps = {
  identifier: '',
  name: '',
  domain: '',
  type: null,
  typeName: '',
  virtual: false,
  hasErrors: false,
  ip: '',
  ip6: '',
  mac: '',
  attachedTo: '',
  providerSpecificInfo: null,
  removeInterface: noop,
  toggleInterfaceEditing: noop,
  setPrimaryInterface: noop,
  setProvisionInterface: noop,
};

export default InterfaceRow;
