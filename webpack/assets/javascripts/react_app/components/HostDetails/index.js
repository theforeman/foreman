import PropTypes from 'prop-types';
import React, { useEffect, useState } from 'react';
import { useSelector, useDispatch, shallowEqual } from 'react-redux';
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
import { sprintf, translate as __ } from '../../common/I18n';
import HostGlobalStatus from './Status/GlobalStatus';

import './HostDetails.scss';
import SkeletonLoader from '../common/SkeletonLoader';
import { STATUS } from '../../constants';

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
