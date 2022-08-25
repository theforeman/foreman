import React from 'react';
import Skeleton from 'react-loading-skeleton';
import { Card, CardHeader, Grid, GridItem } from '@patternfly/react-core';
import GlobalStatusIcon from './GlobalStatusIcon';

const StatusSkeleton = () => (
  <GridItem sm={12} xl2={6}>
    <Card ouiaId="status-card-skeleton" className="pf-c-alert pf-m-success">
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
          <GridItem span={1} rowSpan={2} className="text-center">
            <GlobalStatusIcon status={0} />
          </GridItem>
          <GridItem span={5} style={{ fontSize: '1.5em' }}>
            <Skeleton />
          </GridItem>
          <GridItem span={2} rowSpan={2} className="text-center">
            <div style={{ fontSize: '1.5em' }}>
              <GlobalStatusIcon status={0} />
            </div>
            <Skeleton />
            <br />
            <Skeleton />
          </GridItem>
          <GridItem span={2} rowSpan={2} className="text-center">
            <div style={{ fontSize: '1.5em' }}>
              <GlobalStatusIcon status={1} />
            </div>
            <Skeleton />
            <br />
            <Skeleton />
          </GridItem>
          <GridItem span={2} rowSpan={2} className="text-center">
            <div style={{ fontSize: '1.5em' }}>
              <GlobalStatusIcon status={2} />
            </div>
            <Skeleton />
            <br />
            <Skeleton />
          </GridItem>
          <GridItem span={5}>
            <Skeleton />
          </GridItem>
        </Grid>
      </CardHeader>
    </Card>
  </GridItem>
);

export default StatusSkeleton;
