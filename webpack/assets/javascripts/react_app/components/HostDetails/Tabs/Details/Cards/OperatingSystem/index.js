import PropTypes from 'prop-types';
import React from 'react';
import {
  DescriptionList,
  DescriptionListTerm,
  DescriptionListGroup,
  DescriptionListDescription,
  Button,
} from '@patternfly/react-core';
import { translate as __ } from '../../../../../../common/I18n';
import CardTemplate from '../../../../Templates/CardItem/CardTemplate';
import Slot from '../../../../../common/Slot';
import SkeletonLoader from '../../../../../common/SkeletonLoader';
import DefaultLoaderEmptyState from '../../../../DetailsCard/DefaultLoaderEmptyState';
import { STATUS } from '../../../../../../constants';
import RelativeDateTime from '../../../../../common/dates/RelativeDateTime';

const OperatingSystemCard = ({ status, isExpandedGlobal, hostDetails }) => {
  const {
    architecture_name: architectureName,
    operatingsystem_name: osName,
    reported_data: { boot_time: bootTime } = {},
  } = hostDetails;
  return (
    <CardTemplate
      header={__('Operating system')}
      expandable
      isExpandedGlobal={isExpandedGlobal}
    >
      <DescriptionList isCompact isHorizontal>
        <DescriptionListGroup>
          <DescriptionListTerm>{__('Architecture')}</DescriptionListTerm>
          <DescriptionListDescription>
            <SkeletonLoader
              status={status}
              emptyState={<DefaultLoaderEmptyState />}
            >
              <Button
                variant="link"
                component="a"
                isInline
                href={`/hosts?search=architecture=${architectureName}`}
              >
                {architectureName}
              </Button>
            </SkeletonLoader>
          </DescriptionListDescription>
        </DescriptionListGroup>

        <DescriptionListGroup>
          <DescriptionListTerm>{__('OS')}</DescriptionListTerm>
          <DescriptionListDescription>
            <SkeletonLoader
              status={status}
              emptyState={<DefaultLoaderEmptyState />}
            >
              <Button
                variant="link"
                component="a"
                isInline
                href={`/hosts?search=os_title="${osName}"`}
              >
                {osName}
              </Button>
            </SkeletonLoader>
          </DescriptionListDescription>
        </DescriptionListGroup>
        <Slot
          id="host-details-tab-operating-system"
          multi
          hostDetails={hostDetails}
        />
        <DescriptionListGroup>
          <DescriptionListTerm>{__('Boot time')}</DescriptionListTerm>
          <DescriptionListDescription>
            <SkeletonLoader
              status={status}
              emptyState={<DefaultLoaderEmptyState />}
            >
              {bootTime && <RelativeDateTime date={bootTime} />}
            </SkeletonLoader>
          </DescriptionListDescription>
        </DescriptionListGroup>
      </DescriptionList>
    </CardTemplate>
  );
};

OperatingSystemCard.propTypes = {
  status: PropTypes.string,
  isExpandedGlobal: PropTypes.bool,
  hostDetails: PropTypes.shape({
    architecture_name: PropTypes.string,
    operatingsystem_name: PropTypes.string,
    reported_data: PropTypes.object,
  }),
};

OperatingSystemCard.defaultProps = {
  status: STATUS.PENDING,
  isExpandedGlobal: false,
  hostDetails: {
    architecture_name: undefined,
    operatingsystem_name: undefined,
    reported_data: { boot_time: undefined },
  },
};

export default OperatingSystemCard;
