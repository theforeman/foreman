import React from 'react';
import PropTypes from 'prop-types';
import {
  DescriptionListTerm,
  DescriptionListGroup,
  DescriptionListDescription,
} from '@patternfly/react-core';
import { number_to_human_size as NumberToHumanSize } from 'number_helpers';
import { translate as __ } from '../../../../../../common/I18n';

const VirtOvirt = ({ vm }) => (
  <>
    <DescriptionListGroup>
      <DescriptionListTerm>{__('Name')}</DescriptionListTerm>
      <DescriptionListDescription>{vm.name}</DescriptionListDescription>
    </DescriptionListGroup>
    <DescriptionListGroup>
      <DescriptionListTerm>{__('Cores per socket')}</DescriptionListTerm>
      <DescriptionListDescription>{vm.cores}</DescriptionListDescription>
    </DescriptionListGroup>
    <DescriptionListGroup>
      <DescriptionListTerm>{__('Sockets')}</DescriptionListTerm>
      <DescriptionListDescription>{vm.sockets}</DescriptionListDescription>
    </DescriptionListGroup>
    <DescriptionListGroup>
      <DescriptionListTerm>{__('Memory')}</DescriptionListTerm>
      <DescriptionListDescription>
        {NumberToHumanSize(vm.memory, { strip_insignificant_zeros: true })}
      </DescriptionListDescription>
    </DescriptionListGroup>
    <DescriptionListGroup>
      <DescriptionListTerm>{__('Display')}</DescriptionListTerm>
      <DescriptionListDescription>{vm.display.type}</DescriptionListDescription>
    </DescriptionListGroup>
    {vm.display.type === 'vnc' && (
      <DescriptionListGroup>
        <DescriptionListTerm>{__('Keyboard')}</DescriptionListTerm>
        <DescriptionListDescription>
          {vm.display.keyboard_layout}
        </DescriptionListDescription>
      </DescriptionListGroup>
    )}
    {Object.values(vm.interfaces_attributes).map((nic, index) => (
      <DescriptionListGroup key={`nic-${index}`}>
        <DescriptionListTerm>{__('NIC name')}</DescriptionListTerm>
        <DescriptionListDescription>
          {nic.compute_attributes.name}
        </DescriptionListDescription>
        <DescriptionListTerm>{__('Network')}</DescriptionListTerm>
        <DescriptionListDescription>
          {nic.compute_attributes.network}
        </DescriptionListDescription>
        <DescriptionListTerm>{__('MAC address')}</DescriptionListTerm>
        <DescriptionListDescription>{nic.mac}</DescriptionListDescription>
      </DescriptionListGroup>
    ))}
    {Object.values(vm.volumes_attributes).map((vol, index) => (
      <DescriptionListGroup key={`volume-${index}`}>
        <DescriptionListTerm>{__('Disk')}</DescriptionListTerm>
        <DescriptionListDescription>
          {NumberToHumanSize(vol.size_gb * 1024 ** 3, {
            strip_insignificant_zeros: true,
          })}
        </DescriptionListDescription>
      </DescriptionListGroup>
    ))}
  </>
);

VirtOvirt.propTypes = {
  vm: PropTypes.object,
};

VirtOvirt.defaultProps = {
  vm: undefined,
};

export default VirtOvirt;
