import React from 'react';
import PropTypes from 'prop-types';

import { translate as __ } from '../../../../../react_app/common/I18n';
import { noop } from '../../../../common/helpers';
import InterfaceRow from './components/InterfaceRow';

class InterfaceTable extends React.Component {
  componentDidMount() {
    const {
      data: { interfaces },
      initializeInterfaces,
    } = this.props;
    initializeInterfaces(interfaces);
  }

  renderInterfaces(interfaces) {
    const {
      removeInterface,
      toggleInterfaceEditing,
      setPrimaryInterface,
      setProvisionInterface,
    } = this.props;

    return interfaces.map((interfaceData, idx) => (
      <InterfaceRow
        key={interfaceData.id}
        {...interfaceData}
        removeInterface={removeInterface}
        toggleInterfaceEditing={toggleInterfaceEditing}
        setPrimaryInterface={setPrimaryInterface}
        setProvisionInterface={setProvisionInterface}
      />
    ));
  }

  render() {
    const {
      interfaces,
      data: { tableCssClasses },
    } = this.props;

    return (
      <table className={tableCssClasses} id="interfaceList">
        <thead>
          <tr>
            <th className="hidden-xs" width="3%" />
            <th className="hidden-xs" width="6%" />
            <th className="ellipsis">{__('Identifier')}</th>
            <th className="hidden-xs">{__('Type')}</th>
            <th className="hidden-xs">{__('MAC Address')}</th>
            <th className="hidden-xs">{__('IPv4 Address')}</th>
            <th className="hidden-xs">{__('IPv6 Address')}</th>
            <th className="hidden-xs">{__('FQDN')}</th>
            <th>{__('Actions')}</th>
          </tr>
        </thead>
        <tbody>{this.renderInterfaces(interfaces)}</tbody>
      </table>
    );
  }
}

InterfaceTable.propTypes = {
  data: PropTypes.shape({
    interfaces: PropTypes.array.isRequired,
    tableCssClasses: PropTypes.string,
  }).isRequired,
  interfaces: PropTypes.array.isRequired,
  destroyed: PropTypes.array,
  initializeInterfaces: PropTypes.func,
  removeInterface: PropTypes.func,
  setPrimaryInterface: PropTypes.func,
  setProvisionInterface: PropTypes.func,
};

InterfaceTable.defaultProps = {
  destroyed: [],
  initializeInterfaces: noop,
  removeInterface: noop,
  setPrimaryInterface: noop,
  setProvisionInterface: noop,
};

export default InterfaceTable;
