/* eslint-disable camelcase */
import PropTypes from 'prop-types';
import React, { useEffect } from 'react';
import { useSelector, shallowEqual } from 'react-redux';
import { Link } from 'react-router-dom';
import {
  Flex,
  FlexItem,
  Grid,
  Tab,
  Tabs,
  GridItem,
  Label,
  Title,
  Text,
  TextVariants,
  PageSection,
  Split,
  SplitItem,
} from '@patternfly/react-core';

import RelativeDateTime from '../../components/common/dates/RelativeDateTime';
import {
  selectFillsIDs,
  selectSlotMetadata,
} from '../common/Slot/SlotSelectors';

import { selectIsCollapsed } from '../Layout/LayoutSelectors';
import ActionsBar from './ActionsBar';
import { registerCoreTabs } from './Tabs';
import { HOST_DETAILS_API_OPTIONS, TABS_SLOT_ID } from './consts';

import { translate as __, sprintf } from '../../common/I18n';
import HostGlobalStatus from './Status/GlobalStatus';
import SkeletonLoader from '../common/SkeletonLoader';
import { STATUS } from '../../constants';
import './HostDetails.scss';
import { useAPI } from '../../common/hooks/API/APIHooks';
import TabRouter from './Tabs/TabRouter';
import RedirectToEmptyHostPage from './EmptyState';
import BreadcrumbBar from '../BreadcrumbBar';
import { foremanUrl } from '../../common/helpers';
import { useForemanSettings } from '../../Root/Context/ForemanContext';

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
    state => selectFillsIDs(state, TABS_SLOT_ID),
    shallowEqual
  );

  const slotMetadata = useSelector(state =>
    selectSlotMetadata(state, TABS_SLOT_ID)
  );

  // This is a workaround due to the tabs overflow mechanism in PF4
  useEffect(() => {
    if (tabs?.length) dispatchEvent(new Event('resize'));
  }, [tabs]);
  const hideDetailsTab = useForemanSettings()?.labFeatures === false;

  useEffect(() => {
    registerCoreTabs({
      except: hideDetailsTab ? ['host-details-detail-tab'] : [],
    });
  }, [hideDetailsTab]);

  const activeTab = decodeURI(
    hash
      .slice(2)
      .split('/')[0]
      .split('?')[0] // Remove query params
  );

  const filteredTabs =
    tabs?.filter(
      tab => !slotMetadata?.[tab]?.hideTab?.({ hostDetails: response })
    ) ?? [];

  if (status === STATUS.ERROR) return <RedirectToEmptyHostPage hostname={id} />;
  return (
    <>
      <PageSection
        className="host-details-header-section"
        isFilled
        variant="light"
      >
        <div className="header-top">
          <SkeletonLoader
            skeletonProps={{ width: 300 }}
            status={status || STATUS.PENDING}
          >
            {response.name && (
              <BreadcrumbBar
                isSwitchable
                isPf4
                onSwitcherItemClick={(e, href) => {
                  e.preventDefault();
                  history.push(href);
                }}
                resource={{
                  nameField: 'name',
                  resourceUrl: '/api/v2/hosts?thin=true',
                  switcherItemUrl: '/new/hosts/:name',
                }}
                breadcrumbItems={[
                  { caption: __('Hosts'), url: foremanUrl('/hosts') },
                  { caption: response.name },
                ]}
              />
            )}
          </SkeletonLoader>
          <Grid className="hostname-skeleton-rapper">
            <GridItem span={8}>
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
                        <Label
                          isCompact
                          color="blue"
                          render={({ className, content, componentRef }) => (
                            <Link
                              to={`/hosts?search=os_title="${response?.operatingsystem_name}"`}
                              className={className}
                              innerRef={componentRef}
                              target="_blank"
                              rel="noopener noreferrer"
                            >
                              {content}
                            </Link>
                          )}
                        >
                          {response?.operatingsystem_name}
                        </Label>
                      </SplitItem>
                      <SplitItem>
                        <Label
                          isCompact
                          color="blue"
                          render={({ className, content, componentRef }) => (
                            <Link
                              to={`/hosts?search=architecture=${response?.architecture_name}`}
                              className={className}
                              innerRef={componentRef}
                              target="_blank"
                              rel="noopener noreferrer"
                            >
                              {content}
                            </Link>
                          )}
                        >
                          {response?.architecture_name}
                        </Label>
                      </SplitItem>
                    </Split>
                  </>
                )}
              </SkeletonLoader>
            </GridItem>
            <GridItem offset={8} span={4}>
              <Flex>
                <FlexItem align={{ default: 'alignRight' }}>
                  <ActionsBar
                    computeId={response.compute_resource_id}
                    hostFriendlyId={id}
                    hostId={response.id}
                    hostName={response.name}
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
        {tabs && (
          <TabRouter
            response={response}
            hostName={id}
            status={status}
            tabs={tabs}
            router={history}
          >
            <Tabs
              activeKey={activeTab}
              className={`host-details-tabs tab-width-${
                isNavCollapsed ? '138' : '263'
              }`}
            >
              {filteredTabs.map(tab => (
                <Tab
                  key={tab}
                  eventKey={tab}
                  title={slotMetadata?.[tab]?.title || tab}
                />
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
