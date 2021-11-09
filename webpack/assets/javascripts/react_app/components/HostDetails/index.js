/* eslint-disable camelcase */
import PropTypes from 'prop-types';
import React, { useEffect } from 'react';
import { useSelector, shallowEqual } from 'react-redux';
import {
  Flex,
  FlexItem,
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
  Split,
  SplitItem,
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
import ExperimentalAlert from './ExperimentalAlert';

const HostDetails = ({
  match: {
    params: { id },
  },
  location: { hash },
  history,
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

  const activeTab = decodeURI(hash.slice(2).split('/')[0]);

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
            <GridItem span={9}>
              <SkeletonLoader status={status || STATUS.PENDING}>
                {response && (
                  <>
                    <div className="hostname-wrapper">
                      <SkeletonLoader status={status || STATUS.PENDING}>
                        {response && (
                          <Title
                            className="hostname-truncate"
                            headingLevel="h5"
                            size="2xl"
                          >
                            {response.name}
                          </Title>
                        )}
                      </SkeletonLoader>
                    </div>
                    <Split style={{ display: 'inline-flex' }} hasGutter>
                      <SplitItem>
                        <HostGlobalStatus hostName={id} />
                      </SplitItem>
                      <SplitItem>
                        <Badge> {response?.operatingsystem_name}</Badge>
                      </SplitItem>
                      <SplitItem>
                        <Badge>{response?.architecture_name}</Badge>
                      </SplitItem>
                    </Split>
                  </>
                )}
              </SkeletonLoader>
            </GridItem>
            <GridItem offset={10} span={2}>
              <Flex>
                <FlexItem align={{ default: 'alignRight' }}>
                  <ActionsBar
                    computeId={response.compute_resource_id}
                    hostId={id}
                    permissions={response.permissions}
                    hasReports={!!response.last_report}
                    isBuild={response.build}
                  />
                </FlexItem>
              </Flex>
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
        </div>
        <ExperimentalAlert hostId={id} />
        {tabs && (
          <TabRouter
            response={response}
            hostName={id}
            status={status}
            tabs={tabs}
            router={history}
          >
            <Tabs
              style={{
                width: window.innerWidth - (isNavCollapsed ? 95 : 220),
              }}
              activeKey={activeTab}
            >
              {tabs.map(tab => (
                <Tab key={tab} eventKey={tab} title={tab} />
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
  history: PropTypes.object.isRequired,
};

export default HostDetails;
