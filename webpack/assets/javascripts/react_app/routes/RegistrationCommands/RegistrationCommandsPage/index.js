import React, { useState, useEffect, useCallback } from 'react';
import { useSelector, useDispatch } from 'react-redux';

import {
  Alert,
  Form,
  Grid,
  GridItem,
  Tab,
  Tabs,
  TabContent,
  TabTitleText,
  Title,
} from '@patternfly/react-core';
import { HelpIcon } from '@patternfly/react-icons';

import { translate as __ } from '../../../common/I18n';
import {
  useForemanOrganization,
  useForemanLocation,
} from '../../../Root/Context/ForemanContext';
import { STATUS } from '../../../constants';
import Head from '../../../components/Head';
import Slot from '../../../components/common/Slot';

import {
  selectAPIStatusData,
  selectAPIStatusCommand,
  selectOrganizations,
  selectLocations,
  selectHostGroups,
  selectCommand,
  selectConfigParams,
  selectOperatingSystems,
  selectOperatingSystemTemplate,
  selectSmartProxies,
  selectPluginData,
} from './RegistrationCommandsPageSelectors';
import { dataAction, commandAction } from './RegistrationCommandsPageActions';

import General from './components/General';
import Advanced from './components/Advanced';
import Actions from './components/Actions';
import Command from './components/Command';
import './RegistrationCommandsPage.scss';

const RegistrationCommandsPage = () => {
  const dispatch = useDispatch();

  // Context
  const currentOrganization = useForemanOrganization();
  const currentLocation = useForemanLocation();

  // Form tabs
  const [activeTab, setActiveTab] = useState(0);
  const generalTabRef = React.createRef();
  const advancedTabRef = React.createRef();

  // API statuses
  const apiStatusCommand = useSelector(selectAPIStatusCommand);
  const apiStatusData = useSelector(selectAPIStatusData);
  const isLoading = apiStatusData === STATUS.PENDING;
  const isGenerating = apiStatusCommand === STATUS.PENDING;

  // Form data
  const organizations = useSelector(selectOrganizations);
  const locations = useSelector(selectLocations);
  const hostGroups = useSelector(selectHostGroups);
  const operatingSystems = useSelector(selectOperatingSystems);
  const operatingSystemTemplate = useSelector(selectOperatingSystemTemplate);
  const smartProxies = useSelector(selectSmartProxies);
  const configParams = useSelector(selectConfigParams);
  const pluginData = useSelector(selectPluginData);

  // Form values
  const [organizationId, setOrganizationId] = useState(currentOrganization?.id);
  const [locationId, setLocationId] = useState(currentLocation?.id);
  const [hostGroupId, setHostGroupId] = useState();
  const [operatingSystemId, setOperatingSystemId] = useState();
  const [smartProxyId, setSmartProxyId] = useState();
  const [insecure, setInsecure] = useState(false);
  const [setupRemoteExecution, setSetupRemoteExecution] = useState('');
  const [setupInsights, setSetupInsights] = useState('');
  const [jwtExpiration, setJwtExpiration] = useState(4);
  const [packages, setPackages] = useState('');
  const [updatePackages, setUpdatePackages] = useState(false);
  const [repo, setRepo] = useState('');
  const [repoGpgKeyUrl, setRepoGpgKeyUrl] = useState('');
  const [invalidFields, setInvalidFields] = useState([]);

  // Command
  const command = useSelector(selectCommand);

  // Plugins
  const [pluginValues, setPluginValues] = useState({});

  const handlePluginValue = useCallback(data => {
    setPluginValues(prevValues => ({ ...prevValues, ...data }));
  }, []);

  const handleInvalidField = useCallback((field, isValid) => {
    if (isValid) {
      setInvalidFields(prevFields => prevFields.filter(f => f !== field));
    } else {
      setInvalidFields(prevFields => {
        if (!prevFields.find(f => f === field)) {
          return [...prevFields, field].sort();
        }
        return prevFields;
      });
    }
  }, []);

  const handleSubmit = e => {
    e.preventDefault();

    const params = {
      organizationId,
      locationId,
      hostgroupId: hostGroupId,
      operatingsystemId: operatingSystemId,
      smartProxyId,
      insecure,
      setupRemoteExecution,
      setupInsights,
      jwtExpiration,
      packages,
      repo,
      repoGpgKeyUrl,
      updatePackages,
      ...pluginValues,
    };

    dispatch(commandAction(params));
  };

  const changeTab = (e, tab) => {
    e.preventDefault();
    setActiveTab(tab);
  };

  // Reset form values when Organization / Location is selected
  useEffect(() => {
    setHostGroupId();
    setOperatingSystemId();
    setSmartProxyId();

    dispatch(
      dataAction({ organization_id: organizationId, location_id: locationId })
    );
  }, [dispatch, organizationId, locationId]);

  useEffect(() => {
    if (hostGroupId === undefined && operatingSystemId === undefined) {
      return;
    }

    const params = {
      organization_id: organizationId,
      location_id: locationId,
      hostgroup_id: hostGroupId,
      operatingsystem_id: operatingSystemId,
    };

    dispatch(dataAction(params));

    // Disabled lint warning, need to check only hostgroup_id & operatingsystem_id
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [dispatch, hostGroupId, operatingSystemId]);

  return (
    <>
      <Head>
        <title>{__('Register Host')}</title>
      </Head>
      <Form
        onSubmit={e => handleSubmit(e)}
        className="registration_commands_form"
        isHorizontal
      >
        <Grid hasGutter>
          <GridItem span={12} />
          <GridItem span={6}>
            <Title headingLevel="h1">{__('Register Host')}</Title>
          </GridItem>
          <GridItem span={6}>
            <a
              href="https://docs.theforeman.org/nightly/Managing_Hosts/index-foreman-el.html#registering-a-host-to-project-using-the-global-registration-template_managing-hosts"
              target="_blank"
              rel="noreferrer"
              className="pf-c-button pf-m-secondary pf-m-small pull-right"
            >
              <HelpIcon /> {__('Documentation')}
            </a>
          </GridItem>

          <GridItem span={12}>
            <Tabs
              activeKey={activeTab}
              onSelect={(e, tab) => changeTab(e, tab)}
            >
              <Tab
                eventKey={0}
                title={<TabTitleText>{__('General')}</TabTitleText>}
                tabContentId="generalTab"
                tabContentRef={generalTabRef}
              />

              <Tab
                eventKey={1}
                title={<TabTitleText>{__('Advanced')}</TabTitleText>}
                tabContentId="advancedTab"
                tabContentRef={advancedTabRef}
              />
            </Tabs>
          </GridItem>

          {apiStatusData === STATUS.ERROR && (
            <GridItem span={8}>
              <Alert
                variant="danger"
                title={__(
                  'There was an error while loading the data, see the logs for more information.'
                )}
              />
            </GridItem>
          )}
          <GridItem span={8}>
            <TabContent eventKey={0} id="generalSection" ref={generalTabRef}>
              <div className="pf-c-form">
                <General
                  organizationId={organizationId}
                  organizations={organizations}
                  handleOrganization={setOrganizationId}
                  locationId={locationId}
                  locations={locations}
                  handleLocation={setLocationId}
                  hostGroupId={hostGroupId}
                  hostGroups={hostGroups}
                  handleHostGroup={setHostGroupId}
                  operatingSystemId={operatingSystemId}
                  operatingSystems={operatingSystems}
                  operatingSystemTemplate={operatingSystemTemplate}
                  handleOperatingSystem={setOperatingSystemId}
                  smartProxyId={smartProxyId}
                  smartProxies={smartProxies}
                  handleSmartProxy={setSmartProxyId}
                  insecure={insecure}
                  handleInsecure={setInsecure}
                  handleInvalidField={handleInvalidField}
                  invalidFields={invalidFields}
                  isLoading={isLoading}
                />

                <Slot
                  id="registrationGeneral"
                  organizationId={organizationId}
                  locationId={locationId}
                  hostGroupId={hostGroupId}
                  pluginValues={pluginValues}
                  pluginData={pluginData}
                  onChange={handlePluginValue}
                  handleInvalidField={handleInvalidField}
                  isLoading={isLoading}
                  multi
                />
              </div>
            </TabContent>

            <TabContent
              eventKey={1}
              id="advancedSection"
              ref={advancedTabRef}
              hidden
            >
              <div className="pf-c-form">
                <Advanced
                  configParams={configParams}
                  setupRemoteExecution={setupRemoteExecution}
                  setupInsights={setupInsights}
                  handleInsights={setSetupInsights}
                  handleRemoteExecution={setSetupRemoteExecution}
                  jwtExpiration={jwtExpiration}
                  handleJwtExpiration={setJwtExpiration}
                  handleInvalidField={handleInvalidField}
                  pluginValues={pluginValues}
                  handlePluginValue={handlePluginValue}
                  invalidFields={invalidFields}
                  organizationId={organizationId}
                  locationId={locationId}
                  hostGroupId={hostGroupId}
                  packages={packages}
                  handlePackages={setPackages}
                  repo={repo}
                  handleRepo={setRepo}
                  repoGpgKeyUrl={repoGpgKeyUrl}
                  handleRepoGpgKeyUrl={setRepoGpgKeyUrl}
                  updatePackages={updatePackages}
                  handleUpdatePackages={setUpdatePackages}
                  isLoading={isLoading}
                />
                <Slot
                  id="registrationAdvanced"
                  organizationId={organizationId}
                  locationId={locationId}
                  hostGroupId={hostGroupId}
                  pluginValues={pluginValues}
                  pluginData={pluginData}
                  onChange={handlePluginValue}
                  handleInvalidField={handleInvalidField}
                  isLoading={isLoading}
                  multi
                />
              </div>
            </TabContent>
            <Actions
              isLoading={isLoading}
              isGenerating={isGenerating}
              handleSubmit={handleSubmit}
              invalidFields={invalidFields}
            />
          </GridItem>
          <GridItem span={10}>
            <Command apiStatus={apiStatusCommand} command={command} />
          </GridItem>
        </Grid>
      </Form>
    </>
  );
};

export default RegistrationCommandsPage;
