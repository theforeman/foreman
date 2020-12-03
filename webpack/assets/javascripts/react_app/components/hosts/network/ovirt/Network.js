import React, { useEffect, useState } from 'react';
import PropTypes from 'prop-types';
import { WarningTriangleIcon, ErrorCircleOIcon } from '@patternfly/react-icons';
import { HelpBlock, Grid, Col, Row } from 'patternfly-react';
import { translate as __ } from '../../../../common/I18n';
import Select from "../../../common/forms/Select";

const OvirtNetwork = ({
  name,
  vnic_profile,
  vnic_profiles,
  network,
  networks,
  interface_type,
  interface_types,
  vmExists,
  scope,
}) => {
  const modifySelectFields = (array) => array.map((item)=> ({...item,label: item.name || item.table.name,value: item.id || item.table.id}));
  const [vnicOptions, setVnicOptions] = useState(modifySelectFields(vnic_profiles));
  const [networksOptions, setNetworkOptions] = useState(modifySelectFields(networks));
  const [interfaceTypeOptions, setInterfaceTypeOptions] = useState(modifySelectFields(interface_types));

  const [vnicValue, setVnicValue ] = useState(vnic_profile);
  const [networkValue, setNetworkValue ] = useState(network);
  const [interfaceTypeValue, setInterfaceType ] = useState(interface_type);
  useEffect(() => {
      if (vnicValue) {
          const vnicObject = vnicOptions.filter(vnic_option => vnic_option.id == vnicValue)[0];
          const filtered_networks = networksOptions.filter(network_option => network_option.id === vnicObject.network.id);
          setNetworkValue(filtered_networks[0].id)
          setNetworkOptions(filtered_networks)
      }
  },[vnicValue]);
    return (
          <div className="network-container">
            <Select
              name = { scope + "[vnic_profile]"}
              label={__('Vnic Profile')}
              value = {vnicValue}
              labelClass="col-md-3"
              options={vnicOptions}
              disabled={vmExists}
              allowClear
              className="ovirt_network"
              onChange={event => setVnicValue(event.target.value)}
            />
            <Select
              name =  { scope + "[network]"}
              label={__('Network')}
              labelClass="col-md-3"
              value = {networkValue}
              options={networksOptions}
              disabled={vmExists}
              allowClear
              className="ovirt_network"
              onChange={event => setNetworkValue(event.target.value)}
            />
              <Select
              name =  { scope + "[interface]"}
              label={__('Interface type')}
              labelClass="col-md-3"
              value = {interfaceTypeValue}
              options={interfaceTypeOptions}
              disabled={vmExists}
              allowClear
              key="Network Select"
              className="ovirt_network"

            />
          </div>

);
};

OvirtNetwork.propTypes = {
  name: PropTypes.string,
  vnic_profile: PropTypes.string,
  vnic_profiles: PropTypes.array,
  network: PropTypes.string,
  networks:  PropTypes.array,
  interface_type: PropTypes.string,
  interface_types:  PropTypes.array,
  vmExists: PropTypes.boolean,
  scope: PropTypes.string,
};

OvirtNetwork.defaultProps = {
  name: __('ovirt'),
  vnic_profile: undefined,
  vnic_profiles: [],
  network: undefined,
  networks: [],
  interface_type: undefined,
  interface_types: [],
  vmExists: undefined,
  scope: undefined,

};

export default OvirtNetwork;
