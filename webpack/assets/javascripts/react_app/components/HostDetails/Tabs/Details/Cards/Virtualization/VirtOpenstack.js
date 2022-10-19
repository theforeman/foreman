import React from 'react';
import PropTypes from 'prop-types';
import {
  DescriptionListTerm,
  DescriptionListGroup,
  DescriptionListDescription,
} from '@patternfly/react-core';
import { translate as __ } from '../../../../../../common/I18n';

const VirtOpenstack = ({ vm }) => (
  <>
    <DescriptionListGroup>
      <DescriptionListTerm>{__('Availability zone')}</DescriptionListTerm>
      <DescriptionListDescription>
        {vm.availability_zone}
      </DescriptionListDescription>
    </DescriptionListGroup>
    {vm.all_addresses.map(address => (
      <DescriptionListGroup>
        <DescriptionListTerm>{__('Network')}</DescriptionListTerm>
        <DescriptionListDescription>{address.pool}</DescriptionListDescription>
        <DescriptionListTerm>{__('Floating IP')}</DescriptionListTerm>
        <DescriptionListDescription>{address.ip}</DescriptionListDescription>
        <DescriptionListTerm>{__('Fixed IP')}</DescriptionListTerm>
        <DescriptionListDescription>
          {address.fixed_ip}
        </DescriptionListDescription>
      </DescriptionListGroup>
    ))}
    <DescriptionListGroup>
      <DescriptionListTerm>{__('State')}</DescriptionListTerm>
      <DescriptionListDescription>{vm.state}</DescriptionListDescription>
    </DescriptionListGroup>
    <DescriptionListGroup>
      <DescriptionListTerm>{__('Created at')}</DescriptionListTerm>
      <DescriptionListDescription>{vm.created_at}</DescriptionListDescription>
    </DescriptionListGroup>
    <DescriptionListGroup>
      <DescriptionListTerm>{__('Tenant')}</DescriptionListTerm>
      <DescriptionListDescription>{vm.tenant}</DescriptionListDescription>
    </DescriptionListGroup>
    <DescriptionListGroup>
      <DescriptionListTerm>{__('Flavor')}</DescriptionListTerm>
      <DescriptionListDescription>
        {vm.flavor_with_object}
      </DescriptionListDescription>
    </DescriptionListGroup>
    <DescriptionListGroup>
      <DescriptionListTerm>{__('Security groups')}</DescriptionListTerm>
      <DescriptionListDescription>
        {vm.security_groups}
      </DescriptionListDescription>
    </DescriptionListGroup>
  </>
);

VirtOpenstack.propTypes = {
  vm: PropTypes.object,
};

VirtOpenstack.defaultProps = {
  vm: undefined,
};

export default VirtOpenstack;
