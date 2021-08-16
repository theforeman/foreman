import PropTypes from 'prop-types';
import React, { useEffect } from 'react';
import { useSelector, shallowEqual } from 'react-redux';
import {
  Grid,
  Tab,
  Tabs,
  GridItem,
  Badge,
  Title,
  Breadcrumb,
  BreadcrumbItem,
  Text,
  TextVariants,
  PageSection,
} from '@patternfly/react-core';

import Skeleton from 'react-loading-skeleton';
import RelativeDateTime from '../../components/common/dates/RelativeDateTime';

import { selectFillsIDs } from '../common/Slot/SlotSelectors';
import { selectIsCollapsed } from '../Layout/LayoutSelectors';
import ActionsBar from './ActionsBar';
import { registerCoreTabs } from './Tabs';
import { HOST_DETAILS_API_OPTIONS } from './consts';

import { translate as __, sprintf } from '../../common/I18n';
import HostGlobalStatus from './Status/GlobalStatus';
import SkeletonLoader from '../common/SkeletonLoader';
import { STATUS } from '../../constants';
import './HostDetails.scss';
import { useAPI } from '../../common/hooks/API/APIHooks';
import TabRouter from './Tabs/TabRouter';

const HostDetails = ({
  match: {
    params: { id },
  },
  location: { hash },
}) => {
  const { response, status } = useAPI(
    'get',
    `/api/hosts/${id}`,
    HOST_DETAILS_API_OPTIONS
  );

  const isNavCollapsed = useSelector(selectIsCollapsed);
  const tabs = useSelector(
    state => selectFillsIDs(state, 'host-details-page-tabs'),
    shallowEqual
  );

  // This is a workaround due to the tabs overflow mechanism in PF4
  useEffect(() => {
    if (tabs?.length) dispatchEvent(new Event('resize'));
  }, [tabs]);

  useEffect(() => {
    registerCoreTabs();
  }, []);

  useEffect(() => {
    //  This is a workaround for adding gray background inspiring pf4 desgin
    //  TODO: delete it when pf4 layout (Page copmponent) is implemented in foreman
    document.body.classList.add('pf-gray-background');
    return () => document.body.classList.remove('pf-gray-background');
  }, []);

  return (
    <>
      <PageSection
        className="host-details-header-section"
        isFilled
        variant="light"
      >
        <div style={{ marginLeft: '18px', marginRight: '18px' }}>
          <Breadcrumb style={{ marginTop: '15px' }}>
            <BreadcrumbItem to="/hosts">{__('Hosts')}</BreadcrumbItem>
            <BreadcrumbItem isActive>
              {response.name || <Skeleton />}
            </BreadcrumbItem>
          </Breadcrumb>
          {/* TODO: Replace all br with css */}
          <br />
          <br />
          <Grid>
            <GridItem span={3}>
              <Title headingLevel="h5" size="2xl">
                {/* TODO: Make a generic Skeleton HOC (withSkeleton) */}
                {response.name || <Skeleton />}{' '}
                <HostGlobalStatus hostName={id} />
              </Title>
            </GridItem>
            <GridItem
              style={{ marginTop: '5px', marginRight: '30px' }}
              span={7}
            >
              <Badge key={1}>{response.operatingsystem_name}</Badge>{' '}
              <Badge key={21}>{response.architecture_name}</Badge>
            </GridItem>
            <GridItem span={2}>
              <ActionsBar hostName={response.name} />
            </GridItem>
          </Grid>
          <SkeletonLoader
            skeletonProps={{ width: 400 }}
            status={status || STATUS.PENDING}
          >
            {response && (
              <Text component={TextVariants.span}>
                <RelativeDateTime date={response.created_at} defaultValue="N/A">
                  {date =>
                    sprintf(__('Created %s by %s'), date, response.owner_name)
                  }
                </RelativeDateTime>{' '}
                <RelativeDateTime date={response.updated_at} defaultValue="N/A">
                  {date => sprintf(__('(updated %s)'), date)}
                </RelativeDateTime>
              </Text>
            )}
          </SkeletonLoader>
          <br />
        </div>
        {tabs && (
          <TabRouter
            response={response}
            hostName={id}
            status={status}
            tabs={tabs}
          >
            <Tabs
              style={{
                width: window.innerWidth - (isNavCollapsed ? 95 : 220),
              }}
              activeKey={hash.slice(2).split('/')[0]}
            >
              {tabs.map(tab => (
                <Tab key={tab} eventKey={tab} title={tab} href={`#/${tab}`} />
              ))}
            </Tabs>
          </TabRouter>
        )}
      </PageSection>
    </>
  );
};

HostDetails.propTypes = {
  match: PropTypes.shape({
    params: PropTypes.shape({
      id: PropTypes.string,
    }),
  }).isRequired,
  location: PropTypes.shape({
    hash: PropTypes.string,
  }).isRequired,
};

export default HostDetails;
