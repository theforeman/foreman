import PropTypes from 'prop-types';
import React, { useEffect } from 'react';
import { HashRouter, Route, useHistory } from 'react-router-dom';
import { useSelector } from 'react-redux';
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
import Slot from '../common/Slot';
import { registerCoreTabs } from './Tabs';
import { DEFAULT_TAB, HOST_DETAILS_API_OPTIONS } from './consts';
import { translate as __ } from '../../common/I18n';

import './HostDetails.scss';
import { useAPI } from '../../common/hooks/API/APIHooks';

const HostDetails = ({ match, location: { hash } }) => {
  const { response, status } = useAPI(
    'get',
    `/api/hosts/${match.params.id}`,
    HOST_DETAILS_API_OPTIONS
  );

  const history = useHistory();
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
    if (!hash) history.push(`#/${DEFAULT_TAB}`);
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
            <GridItem span={2}>
              <Title headingLevel="h5" size="2xl">
                {/* TODO: Make a generic Skeleton HOC (withSkeleton) */}
                {response.name || <Skeleton />}
              </Title>
            </GridItem>
            <GridItem style={{ marginTop: '5px', marginLeft: '10px' }} span={8}>
              <Badge key={1}>{response.operatingsystem_name}</Badge>{' '}
              <Badge key={21}>{response.architecture_name}</Badge>
            </GridItem>
            <GridItem span={2}>
              <ActionsBar hostName={response.name || <Skeleton />} />
            </GridItem>
          </Grid>
          <Text style={{ fontStyle: 'italic' }} component={TextVariants.p}>
            {/* TODO: extracting text and remove timeago usage in favor i18n */}
            {response.name ? (
              <div>
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
              </div>
            ) : (
              <Skeleton width={400} />
            )}
          </Text>
          <br />
        </div>
        <HashRouter>
          <Tabs
            style={{
              width: window.innerWidth - (isNavCollapsed ? 95 : 220),
            }}
            activeKey={hash.slice(2)}
          >
            {tabs?.map(tab => (
              <Tab key={tab} eventKey={tab} title={tab} href={`#${tab}`}>
                <Route path={`/${tab}`}>
                  <Slot
                    response={response}
                    status={status}
                    id="host-details-page-tabs"
                    fillID={tab}
                    router={history}
                  />
                </Route>
              </Tab>
            ))}
          </Tabs>
        </HashRouter>
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
