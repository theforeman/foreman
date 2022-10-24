import PropTypes from 'prop-types';
import React from 'react';
import {
  DescriptionList,
  DescriptionListTerm,
  DescriptionListGroup,
  DescriptionListDescription,
} from '@patternfly/react-core';
import { translate as __ } from '../../../../../../common/I18n';
import CardTemplate from '../../../../Templates/CardItem/CardTemplate';
import SkeletonLoader from '../../../../../common/SkeletonLoader';
import DefaultLoaderEmptyState from '../../../../DetailsCard/DefaultLoaderEmptyState';
import { STATUS } from '../../../../../../constants';

const BiosCard = ({ status, hostDetails }) => {
  const {
    reported_data: {
      bios_vendor: biosVendor,
      bios_version: biosVersion,
      bios_release_date: biosReleaseDate,
    } = {},
  } = hostDetails;

  return (
    <CardTemplate header={__('BIOS')} expandable masonryLayout>
      <DescriptionList isCompact isHorizontal>
        <DescriptionListGroup>
          <DescriptionListTerm>{__('Vendor')}</DescriptionListTerm>
          <DescriptionListDescription>
            <SkeletonLoader
              status={status}
              emptyState={<DefaultLoaderEmptyState />}
            >
              {biosVendor}
            </SkeletonLoader>
          </DescriptionListDescription>
        </DescriptionListGroup>

        <DescriptionListGroup>
          <DescriptionListTerm>{__('Version')}</DescriptionListTerm>
          <DescriptionListDescription>
            <SkeletonLoader
              status={status}
              emptyState={<DefaultLoaderEmptyState />}
            >
              {biosVersion}
            </SkeletonLoader>
          </DescriptionListDescription>
        </DescriptionListGroup>

        <DescriptionListGroup>
          <DescriptionListTerm>{__('Release date')}</DescriptionListTerm>
          <DescriptionListDescription>
            <SkeletonLoader
              status={status}
              emptyState={<DefaultLoaderEmptyState />}
            >
              {biosReleaseDate}
            </SkeletonLoader>
          </DescriptionListDescription>
        </DescriptionListGroup>
      </DescriptionList>
    </CardTemplate>
  );
};

BiosCard.propTypes = {
  status: PropTypes.string,
  hostDetails: PropTypes.shape({
    reported_data: PropTypes.object,
  }),
};

BiosCard.defaultProps = {
  status: STATUS.PENDING,
  hostDetails: {
    reported_data: {},
  },
};

export default BiosCard;
