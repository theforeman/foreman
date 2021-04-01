import React, { Fragment } from 'react';
import { useSelector } from 'react-redux';
import { PageSection, Grid, GridItem, Title } from '@patternfly/react-core';
import { foremanUrl } from '../../../foreman_tools';
import { useAPI } from '../../common/hooks/API/APIHooks';
import Status from './Status';
import StatusSkeleton from './Status/StatusSkeleton';
import { translate as __ } from '../../common/I18n';
import SkeletonLoader from '../common/SkeletonLoader';
import { STATUS } from '../../constants';
import { API_OPTIONS } from './HostStatusesConstants';
import { selectHostStatusesNames } from './HostStatusesSelectors';

import './HostStatuses.scss';

const HostStatuses = () => {
  const url = foremanUrl('/api/v2/host_statuses?per_page=99');
  const { status = STATUS.PENDING } = useAPI('get', url, API_OPTIONS);

  const Skeleton = () => (
    <Fragment>
      <StatusSkeleton />
      <StatusSkeleton />
    </Fragment>
  );

  const statuses = useSelector(state => selectHostStatusesNames(state));

  return (
    <PageSection padding className="host-statuses-page">
      <Grid hasGutter>
        <GridItem span={12}>
          <Title headingLevel="h5" size="xl">
            {__('Host Status Overview')}
          </Title>
        </GridItem>
        <SkeletonLoader customSkeleton={<Skeleton />} status={status}>
          {statuses.map((name, i) => (
            <Status key={i} name={name} />
          ))}
        </SkeletonLoader>
      </Grid>
    </PageSection>
  );
};

export default HostStatuses;
