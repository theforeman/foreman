import React from 'react';
import PropTypes from 'prop-types';
import {
  DescriptionListTerm,
  DescriptionListGroup,
  DescriptionListDescription,
} from '@patternfly/react-core';
import { number_to_human_size as NumberToHumanSize } from 'number_helpers';
import { translate as __ } from '../../../../../../common/I18n';

const VirtVmware = ({ vm }) => (
  <>
    <DescriptionListGroup>
      <DescriptionListTerm>{__('Datacenter')}</DescriptionListTerm>
      <DescriptionListDescription>{vm.datacenter}</DescriptionListDescription>
    </DescriptionListGroup>
    <DescriptionListGroup>
      <DescriptionListTerm>{__('Cluster')}</DescriptionListTerm>
      <DescriptionListDescription>{vm.cluster}</DescriptionListDescription>
    </DescriptionListGroup>
    <DescriptionListGroup>
      <DescriptionListTerm>{__('Memory')}</DescriptionListTerm>
      <DescriptionListDescription>
        {NumberToHumanSize(vm.memory_mb * 1024 ** 2, {
          strip_insignificant_zeros: true,
        })}
      </DescriptionListDescription>
    </DescriptionListGroup>
    <DescriptionListGroup>
      <DescriptionListTerm>{__('Public IP address')}</DescriptionListTerm>
      <DescriptionListDescription>
        {vm.public_ip_address}
      </DescriptionListDescription>
    </DescriptionListGroup>
    <DescriptionListGroup>
      <DescriptionListTerm>{__('MAC address')}</DescriptionListTerm>
      <DescriptionListDescription>
        {vm.interfaces_attributes[0]?.mac}
      </DescriptionListDescription>
    </DescriptionListGroup>
    <DescriptionListGroup>
      <DescriptionListTerm>{__('CPUs')}</DescriptionListTerm>
      <DescriptionListDescription>{vm.cpus}</DescriptionListDescription>
    </DescriptionListGroup>
    <DescriptionListGroup>
      <DescriptionListTerm>{__('Cores per socket')}</DescriptionListTerm>
      <DescriptionListDescription>
        {vm.corespersocket}
      </DescriptionListDescription>
    </DescriptionListGroup>
    <DescriptionListGroup>
      <DescriptionListTerm>{__('Firmware')}</DescriptionListTerm>
      <DescriptionListDescription>{vm.firmware}</DescriptionListDescription>
    </DescriptionListGroup>
    <DescriptionListGroup>
      <DescriptionListTerm>{__('Hypervisor')}</DescriptionListTerm>
      <DescriptionListDescription>{vm.hypervisor}</DescriptionListDescription>
    </DescriptionListGroup>
    <DescriptionListGroup>
      <DescriptionListTerm>{__('Connection state')}</DescriptionListTerm>
      <DescriptionListDescription>
        {vm.connection_state}
      </DescriptionListDescription>
    </DescriptionListGroup>
    <DescriptionListGroup>
      <DescriptionListTerm>{__('Overall status')}</DescriptionListTerm>
      <DescriptionListDescription>
        {vm.overall_status}
      </DescriptionListDescription>
    </DescriptionListGroup>
    <DescriptionListGroup>
      <DescriptionListTerm>{__('Annotation notes')}</DescriptionListTerm>
      <DescriptionListDescription>{vm.annotation}</DescriptionListDescription>
    </DescriptionListGroup>
  </>
);

VirtVmware.propTypes = {
  vm: PropTypes.object,
};

VirtVmware.defaultProps = {
  vm: undefined,
};

export default VirtVmware;
