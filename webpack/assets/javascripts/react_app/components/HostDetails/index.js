import PropTypes from 'prop-types';
import React, { useEffect, useState } from 'react';
import { useSelector, useDispatch } from 'react-redux';
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
  PageSectionVariants,
} from '@patternfly/react-core';

import Skeleton from 'react-loading-skeleton';
import RelativeDateTime from '../../components/common/dates/RelativeDateTime';
import StatusAlert from './Status';

import { foremanUrl } from '../../../foreman_tools';
import { get } from '../../redux/API';
import { selectAPIResponse } from '../../redux/API/APISelectors';

import Properties from './Properties';
import ParametersCard from './Parameters';
import InterfacesCard from './Interfaces';
import AuditCard from './Audits';
import ActionsBar from './ActionsBar';

import './HostDetails.scss';

const HostDetails = ({ match }) => {
  const dispatch = useDispatch();
  const [activeTab, setActiveTab] = useState(0);
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

  useEffect(() => {
    document.body.classList.add('transprenet-border');
  }, []);

  const handleTabClick = (event, tabIndex) => {
    setActiveTab(tabIndex);
  };
  return (
    <>
      <PageSection className="header" variant={PageSectionVariants.light}>
        <div style={{ marginLeft: '18px', marginRight: '18px' }}>
          <Breadcrumb style={{ marginTop: '15px' }}>
            <BreadcrumbItem to="/hosts">Hosts</BreadcrumbItem>
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
      </PageSection>
      <Tabs
        style={{
          marginLeft: '-18px',
          marginRight: '-18px',
          background: 'white',
        }}
        activeKey={activeTab}
        onSelect={handleTabClick}
      >
        <Tab eventKey={0} title="Details">
          <div id="test">
            <br />
            <Grid>
              <GridItem offset={3} span={4}>
                <StatusAlert
                  status={response ? response.global_status_label : null}
                />
              </GridItem>
            </Grid>
            <br />
            <br />
            <Grid>
              <GridItem span={3} rowSpan={3}>
                <Properties hostData={response} />
              </GridItem>
              <GridItem style={{ marginLeft: '40px' }} span={3}>
                <ParametersCard paramters={response.all_parameters} />
              </GridItem>
              <GridItem style={{ marginLeft: '40px' }} span={3} rowSpan={2}>
                <AuditCard hostName={response.name} />
              </GridItem>
              <GridItem
                style={{ marginLeft: '40px', marginTop: '20px' }}
                offset={3}
                span={3}
              >
                <InterfacesCard interfaces={response.interfaces} />
              </GridItem>
            </Grid>
          </div>
        </Tab>
        <Tab eventKey={1} title="Facts">
          WIP
        </Tab>
        <Tab eventKey={2} title="Tasks">
          WIP
        </Tab>
        <Tab eventKey={3} title="Content">
          WIP
        </Tab>
      </Tabs>
    </>
  );
};

HostDetails.propTypes = {
  match: PropTypes.shape({
    params: PropTypes.shape({
      id: PropTypes.string,
    }),
  }).isRequired,
};

export default HostDetails;
