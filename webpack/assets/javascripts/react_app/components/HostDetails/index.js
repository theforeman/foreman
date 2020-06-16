import React, { useEffect } from 'react';
import { useSelector, useDispatch } from 'react-redux';
import {
  Grid,
  GridItem,
  Title,
  Breadcrumb,
  BreadcrumbItem,
  Text,
  TextVariants,
  Divider,
} from '@patternfly/react-core';
import StatusAlert from './Status';

import { foremanUrl } from '../../../foreman_tools';
import Skeleton from 'react-loading-skeleton';
import TimeAgo from 'react-timeago';
import { get } from '../../redux/API';
import { selectAPIResponse } from '../../redux/API/APISelectors';

import Properties from './Properties';
import ParametersCard from './Parameters';
import InterfacesCard from './Interfaces';
import AuditCard from './Audits';

const HostDetails = ({ match }) => {
  const dispatch = useDispatch();
  const response = useSelector(state =>
    selectAPIResponse(state, 'HOST_DETAILS')
  );
  useEffect(() => {
    dispatch(
      get({
        key: 'HOST_DETAILS',
        url: foremanUrl(`/api/hosts/${match.params.id}`),
      })
    );
  }, [match.params.id, dispatch]);

  return (
    <>
      {response.name ? (
        <Breadcrumb style={{ marginTop: '15px' }}>
          <BreadcrumbItem to="/hosts">Hosts</BreadcrumbItem>
          <BreadcrumbItem isActive>{response.name}</BreadcrumbItem>
        </Breadcrumb>
      ) : (
        <Skeleton />
      )}
      {/* TODO: Replace all br with css */}
      <br />
      <Divider />
      <br />
      <Title headingLevel="h5" size="2xl">
        {response.name || <Skeleton />}
      </Title>
      {response.name ? (
        <Text style={{ fontStyle: 'italic' }} component={TextVariants.p}>
          {/* TODO: extracting text */}
          created <TimeAgo date={response.created_at} />
          {` by ${response.owner_name} (updated`}{' '}
          <TimeAgo date={response.updated_at} />)
        </Text>
      ) : (
        <Skeleton />
      )}
      <br />
      <Grid>
        <GridItem offset={3} span={4}>
          {response.name ? (
            <StatusAlert status={response.global_status_label} />
          ) : (
            <Skeleton />
          )}
        </GridItem>
      </Grid>
      <br />
      <br />
      <Grid>
        <GridItem span={3} rowSpan={3}>
          {response.name ? (
            <Properties hostData={response} />
          ) : (
            <Skeleton count={15} />
          )}
        </GridItem>
        <GridItem style={{ marginLeft: '40px' }} span={3}>
          {response.name ? (
            <ParametersCard paramters={response.all_parameters} />
          ) : (
            <Skeleton count={10} />
          )}
        </GridItem>
        <GridItem style={{ marginLeft: '40px' }} span={3} rowSpan={2}>
          {response.name ? (
            <AuditCard hostName={response.name} />
          ) : (
            <Skeleton count={5} />
          )}
        </GridItem>
        <GridItem
          style={{ marginLeft: '40px', marginTop: '20px' }}
          offset={3}
          span={3}
        >
          {response.name ? (
            <InterfacesCard interfaces={response.interfaces} />
          ) : (
            <Skeleton count={10} />
          )}
        </GridItem>
      </Grid>
    </>
  );
};

export default HostDetails;
