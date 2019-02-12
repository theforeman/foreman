import UUID from 'uuid/v1';
import React from 'react';
import PropTypes from 'prop-types';
import classNames from 'classnames';
import { OverlayTrigger, Tooltip } from 'patternfly-react';
import $ from 'jquery';

import { translate as __, sprintf } from '../../../../../react_app/common/I18n';
import { noop } from '../../../../common/helpers';
import { fqdn } from '../../../../../foreman_hosts';

class InterfaceRow extends React.Component {
  getHiddenFields() {
    return document.getElementById(`interfaceHidden${this.props.id}`);
  }

  isVirtual() {
    const virtualTypes = ['Nic::Bond', 'Nic::Bridge'];
    return this.props.virtual || virtualTypes.indexOf(this.props.type) >= 0;
  }

  nicInfo() {
    if (this.isVirtual()) {
      // common virtual
      if (this.props.attachedTo !== '')
        return sprintf(__('virtual attached to %s'), this.props.attachedTo);
      return __('virtual');
    }

    // provider specific
    if (typeof window.providerSpecificNICInfo === 'function')
      return window.providerSpecificNICInfo($(this.getHiddenFields()));
    return __('physical');
  }

  getFqdn() {
    const { name, domain } = this.props;
    return fqdn(name, domain);
  }

  editInterface() {
    window.edit_interface(this.props.id);
  }

  render() {
    const {
      id,
      identifier,
      typeName,
      primary,
      provision,
      mac,
      ip,
      ip6,
      hasErrors,
      removeInterface,
      setProvisionInterface,
      setPrimaryInterface,
    } = this.props;

    const getTooltip = text => <Tooltip id={UUID()}>{text}</Tooltip>;
    let primaryClasses = 'glyphicon glyphicon-tag primary-flag';
    if (primary) primaryClasses += ' active';
    let provisionClasses = 'glyphicon glyphicon-hdd provision-flag';
    if (provision) provisionClasses += ' active';

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
              className={primaryClasses}
              onClick={() => setPrimaryInterface(id)}
            />
          </OverlayTrigger>
          <OverlayTrigger
            overlay={getTooltip(__('Provisioning'))}
            placement="top"
            trigger={['hover', 'focus']}
          >
            <i
              className={provisionClasses}
              onClick={() => setProvisionInterface(id)}
            />
          </OverlayTrigger>
        </td>
        <td className="identifier ellipsis">{identifier}</td>
        <td className="type hidden-xs">
          {typeName}
          <div className="additional-info">{this.nicInfo()}</div>
        </td>
        <td className="mac hidden-xs">{mac}</td>
        <td className="ip hidden-xs">{ip}</td>
        <td className="ip6 hidden-xs">{ip6}</td>
        <td className="fqdn hidden-xs">{this.getFqdn()}</td>
        <td>
          <button
            type="button"
            className="btn btn-default"
            onClick={() => this.editInterface()}
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
  hasErrors: PropTypes.bool,
  removeInterface: PropTypes.func,
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
  removeInterface: noop,
  setPrimaryInterface: noop,
  setProvisionInterface: noop,
};

export default InterfaceRow;
