import React from 'react';
import PropTypes from 'prop-types';
import {
  Card,
  CardHeader,
  Grid,
  GridItem,
  Skeleton,
} from '@patternfly/react-core';
import GlobalStatusIcon from './GlobalStatusIcon';
import { translate as __ } from '../../../common/I18n';

// one Total/Owned column of the loaded card (Status/index.js): same icon size
// and two body-size lines in the status-count grid, so nothing jumps on load
const CountSkeleton = ({ status }) => (
  <GridItem span={2} rowSpan={2} className="status-count text-center">
    <div>
      <GlobalStatusIcon status={status} size="lg" />
    </div>
    <Skeleton fontSize="sm" screenreaderText={__('Loading')} />
    <Skeleton fontSize="sm" />
  </GridItem>
);

CountSkeleton.propTypes = {
  status: PropTypes.number,
};

CountSkeleton.defaultProps = {
  status: undefined,
};

const StatusSkeleton = () => (
  <GridItem sm={12} xl2={6}>
    {/* eslint-disable-next-line @theforeman/rules/prefer-pf-components, @theforeman/rules/prefer-pf-props */}
    <Card ouiaId="status-card-skeleton" className="pf-v6-c-alert pf-m-success">
      <CardHeader
        onExpand={() => {}}
        toggleButtonProps={{
          id: 'toggle-button',
          'aria-label': 'Details',
          'aria-labelledby': 'titleId toggle-button',
          'aria-expanded': false,
        }}
      >
        <Grid className="w-100" hasGutter>
          <GridItem span={1} rowSpan={2}>
            <GlobalStatusIcon status={0} size="heading_2xl" />
          </GridItem>
          <GridItem span={5}>
            {/* matches the loaded <Title size="xl"> */}
            <Skeleton fontSize="xl" />
          </GridItem>
          <CountSkeleton status={0} />
          <CountSkeleton status={1} />
          <CountSkeleton status={2} />
          <GridItem span={5}>
            <Skeleton fontSize="sm" />
          </GridItem>
        </Grid>
      </CardHeader>
    </Card>
  </GridItem>
);

export default StatusSkeleton;
