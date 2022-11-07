import PropTypes from 'prop-types';
import React, { useState } from 'react';
import {
  Label,
  DescriptionList,
  DescriptionListTerm,
  DescriptionListGroup,
  DescriptionListDescription,
  Button,
  Grid,
  GridItem,
  Accordion,
  AccordionItem,
  AccordionToggle,
  AccordionContent,
} from '@patternfly/react-core';
import { TagIcon, HddIcon } from '@patternfly/react-icons';
import { translate as __ } from '../../../../../../common/I18n';
import { STATUS } from '../../../../../../constants';
import DefaultLoaderEmptyState from '../../../../DetailsCard/DefaultLoaderEmptyState';

const types = {
  interface: __('Interface'),
  bridge: __('Bridge'),
  bmc: __('BMC'),
};
const NICDescriptionList = ({ status, foremanInterface }) => {
  const {
    identifier,
    primary,
    provision,
    type,
    mac,
    mtu,
    ip,
    ip6,
    fqdn,
    subnet_id: subnetID,
    subnet_name: subnetName,
    subnet6_id: subnet6ID,
    subnet6_name: subnet6Name,
  } = foremanInterface;
  const [isExpanded, setIsExpanded] = useState(primary);
  return (
    <Accordion className="interface-accordion">
      <AccordionItem>
        <AccordionToggle
          onClick={() => {
            setIsExpanded(curr => !curr);
          }}
          isExpanded={isExpanded}
        >
          <Grid>
            <GridItem span={7} className="interface-name">
              {identifier || (
                <span className="disabled-text">{__('No name')}</span>
              )}
              {primary && <TagIcon title={__('Primary')} />}
              {provision && <HddIcon title={__('Provision')} />}
            </GridItem>
            <GridItem span={4}>
              <Label isCompact color="blue">
                {types[type] || type}
              </Label>
            </GridItem>
          </Grid>
        </AccordionToggle>
        <AccordionContent isHidden={!isExpanded}>
          <DescriptionList isCompact>
            <DescriptionListGroup>
              <DescriptionListTerm>{__('FQDN')}</DescriptionListTerm>
              <DescriptionListDescription>
                {fqdn || <DefaultLoaderEmptyState />}
              </DescriptionListDescription>
            </DescriptionListGroup>
            <DescriptionListGroup>
              <DescriptionListTerm>{__('IPv4')}</DescriptionListTerm>
              <DescriptionListDescription>
                {ip || <DefaultLoaderEmptyState />}
              </DescriptionListDescription>
            </DescriptionListGroup>
            <DescriptionListGroup>
              <DescriptionListTerm>{__('IPv6')}</DescriptionListTerm>
              <DescriptionListDescription>
                {ip6 || <DefaultLoaderEmptyState />}
              </DescriptionListDescription>
            </DescriptionListGroup>
            <DescriptionListGroup>
              <DescriptionListTerm>{__('MAC')}</DescriptionListTerm>
              <DescriptionListDescription>
                {mac || <DefaultLoaderEmptyState />}
              </DescriptionListDescription>
            </DescriptionListGroup>
            {subnetID && (
              <DescriptionListGroup>
                <DescriptionListTerm>{__('Subnet')}</DescriptionListTerm>
                <DescriptionListDescription>
                  <Button
                    variant="link"
                    component="a"
                    isInline
                    href={`/subnets/${subnetID}/edit`}
                  >
                    {subnetName}
                  </Button>
                </DescriptionListDescription>
              </DescriptionListGroup>
            )}
            {subnet6ID && (
              <DescriptionListGroup>
                <DescriptionListTerm>{__('IPv6 subnet')}</DescriptionListTerm>
                <DescriptionListDescription>
                  <Button
                    variant="link"
                    component="a"
                    isInline
                    href={`/subnets/${subnet6ID}/edit`}
                  >
                    {subnet6Name}
                  </Button>
                </DescriptionListDescription>
              </DescriptionListGroup>
            )}
            <DescriptionListGroup>
              <DescriptionListTerm>{__('MTU')}</DescriptionListTerm>
              <DescriptionListDescription>
                {mtu || <DefaultLoaderEmptyState />}
              </DescriptionListDescription>
            </DescriptionListGroup>
          </DescriptionList>
        </AccordionContent>
      </AccordionItem>
    </Accordion>
  );
};

NICDescriptionList.propTypes = {
  status: PropTypes.string,
  foremanInterface: PropTypes.object,
};

NICDescriptionList.defaultProps = {
  status: STATUS.PENDING,
  foremanInterface: {},
};

export default NICDescriptionList;
