/* eslint-disable camelcase */
import PropTypes from 'prop-types';
import React, { useEffect, useState } from 'react';
import { useSelector, useDispatch } from 'react-redux';
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

import { foremanUrl } from '../../../foreman_tools';
import { get } from '../../redux/API';
import {
  selectAPIResponse,
  selectAPIStatus,
} from '../../redux/API/APISelectors';
import { selectFillsIDs } from '../common/Slot/SlotSelectors';
import { selectIsCollapsed } from '../Layout/LayoutSelectors';
import ActionsBar from './ActionsBar';
import Slot from '../common/Slot';
import { registerCoreTabs } from './Tabs';
import { translate as __ } from '../../common/I18n';
import HostGlobalStatus from './Status/GlobalStatus';
import ExperimentalAlert from './ExperimentalAlert';
import SkeletonLoader from '../common/SkeletonLoader';
import { STATUS } from '../../constants';
import './HostDetails.scss';


const HostDetails = ({
  match: {
    params: { id },
  },
  location: { hash },
}) => {
  const dispatch = useDispatch();
  const [activeTab, setActiveTab] = useState('Overview');
  const response = useSelector(state =>
    selectAPIResponse(state, 'HOST_DETAILS')
  );
  const status = useSelector(state => selectAPIStatus(state, 'HOST_DETAILS'));
  const isNavCollapsed = useSelector(selectIsCollapsed);
  const tabs = useSelector(state =>
    selectFillsIDs(state, 'host-details-page-tabs')
  );

  // This is a workaround due to the tabs overflow mechanism in PF4
  useEffect(() => {
    if (tabs?.length) dispatchEvent(new Event('resize'));
  }, [tabs]);

  useEffect(() => {
    registerCoreTabs();
  }, []);

  useEffect(() => {
    if (hash) setActiveTab(hash.slice(1));
  }, [hash]);

  useEffect(() => {
    dispatch(
      get({
        key: 'HOST_DETAILS',
        url: foremanUrl(`/api/hosts/${id}`),
      })
    );
  }, [id, dispatch]);

  useEffect(() => {
    //  This is a workaround for adding gray background inspiring pf4 desgin
    //  TODO: delete it when pf4 layout (Page copmponent) is implemented in foreman
    document.body.classList.add('pf-gray-background');
    return () => document.body.classList.remove('pf-gray-background');
  }, []);

  const handleTabClick = (event, tabIndex) => {
    setActiveTab(tabIndex);
  };

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
                  />
                </FlexItem>
              </Flex>
            </GridItem>
          </Grid>
          <Text style={{ fontStyle: 'italic' }} component={TextVariants.p}>
            {/* TODO: extracting text and remove timeago usage in favor i18n */}
            {response.name ? (
              <span>
                created{' '}
                <RelativeDateTime
                  date={response.created_at}
                  defaultValue="N/A"
                />{' '}
                by {response.owner_name} (updated{' '}
                <RelativeDateTime
                  date={response.updated_at}
                  defaultValue="N/A"
                />
                )
              </span>
            ) : (
              <Skeleton width={400} />
            )}
          </Text>
          <br />
        </div>
        <ExperimentalAlert hostId={id} />
        <Tabs
          style={{
            width: window.innerWidth - (isNavCollapsed ? 95 : 220),
          }}
          activeKey={activeTab}
          onSelect={handleTabClick}
        >
          {tabs &&
            tabs.map(tab => (
              <Tab key={tab} eventKey={tab} title={tab}>
                <Slot
                  hostName={id}
                  response={response}
                  status={status}
                  id="host-details-page-tabs"
                  fillID={tab}
                />
              </Tab>
            ))}
        </Tabs>
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
