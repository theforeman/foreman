import PropTypes from 'prop-types';
import React from 'react';
import {
  DescriptionList,
  DescriptionListTerm,
  DescriptionListGroup,
  DescriptionListDescription,
  Tooltip,
} from '@patternfly/react-core';
import humanizeDuration from 'humanize-duration';
import { translate as __, documentLocale } from '../../../../../../common/I18n';
import CardTemplate from '../../../../Templates/CardItem/CardTemplate';
import Slot from '../../../../../common/Slot';
import SkeletonLoader from '../../../../../common/SkeletonLoader';
import DefaultLoaderEmptyState from '../../../../DetailsCard/DefaultLoaderEmptyState';
import { STATUS } from '../../../../../../constants';

const ProvisioningCard = ({ status, hostDetails }) => {
  const {
    initiated_at: initiatedAt,
    installed_at: installedAt,
    token,
    pxe_loader: PXELoader,
  } = hostDetails;

  const dateOptions = {
    largest: 1,
    language: documentLocale(),
    fallbacks: ['en'],
    round: true,
  };

  const getWordsDurations = duration =>
    duration > 0 && duration < 1000
      ? __('Less than a second')
      : humanizeDuration(duration, dateOptions);

  const initiateDate = new Date(initiatedAt);
  const installedDate = new Date(installedAt);
  const duration =
    initiatedAt &&
    installedAt &&
    Math.abs(installedDate.getTime() + 500000 - initiateDate.getTime());
  return (
    <CardTemplate header={__('Provisioning')} expandable masonryLayout>
      <DescriptionList isCompact isHorizontal>
        <DescriptionListGroup>
          <DescriptionListTerm>{__('Build duration')}</DescriptionListTerm>
          <DescriptionListDescription>
            <SkeletonLoader
              status={status}
              emptyState={<DefaultLoaderEmptyState />}
            >
              {(duration || duration === 0) && (
                <Tooltip
                  content={`${Math.round(duration / 1000)} ${__('seconds')}`}
                >
                  <span>{getWordsDurations(duration)}</span>
                </Tooltip>
              )}
            </SkeletonLoader>
          </DescriptionListDescription>
        </DescriptionListGroup>
        <DescriptionListGroup>
          <DescriptionListTerm>{__('Token')}</DescriptionListTerm>
          <DescriptionListDescription>
            <SkeletonLoader
              status={status}
              emptyState={<DefaultLoaderEmptyState />}
            >
              {token}
            </SkeletonLoader>
          </DescriptionListDescription>
        </DescriptionListGroup>
        <Slot
          id="host-details-tab-operating-system"
          multi
          hostDetails={hostDetails}
        />
        <DescriptionListGroup>
          <DescriptionListTerm>{__('PXE loader')}</DescriptionListTerm>
          <DescriptionListDescription>
            <SkeletonLoader
              status={status}
              emptyState={<DefaultLoaderEmptyState />}
            >
              {PXELoader}
            </SkeletonLoader>
          </DescriptionListDescription>
        </DescriptionListGroup>
      </DescriptionList>
    </CardTemplate>
  );
};

ProvisioningCard.propTypes = {
  status: PropTypes.string,
  hostDetails: PropTypes.shape({
    initiated_at: PropTypes.string,
    installed_at: PropTypes.string,
    token: PropTypes.string,
    pxe_loader: PropTypes.string,
  }),
};

ProvisioningCard.defaultProps = {
  status: STATUS.PENDING,
  hostDetails: {},
};

export default ProvisioningCard;
