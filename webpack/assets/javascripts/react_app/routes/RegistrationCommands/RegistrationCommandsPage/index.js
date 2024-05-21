/* eslint-disable max-lines */
import React, { useState, useEffect, useCallback } from 'react';
import { useSelector, useDispatch } from 'react-redux';

import {
  Alert,
  Button,
  Form,
  Grid,
  GridItem,
  Tab,
  Tabs,
  TabContent,
  TabTitleText,
} from '@patternfly/react-core';

import { translate as __ } from '../../../common/I18n';
import { getDocsURL } from '../../../common/helpers';
import {
  useForemanOrganization,
  useForemanLocation,
} from '../../../Root/Context/ForemanContext';
import { STATUS } from '../../../constants';
import PageLayout from '../../common/PageLayout/PageLayout';
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
  const [repoData, setRepoData] = useState([]);
  const [repoDataInternal, setRepoDataInternal] = useState([]);
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
      repoData,
      updatePackages,
      ...pluginValues,
    };

    dispatch(commandAction(params));
  };

  const changeTab = (e, tab) => {
    e.preventDefault();
    setActiveTab(tab);
  };

  // Update internal repoData that is submitted to server
  useEffect(() => {
    setRepoData(
      repoDataInternal
        .filter(r => r.repository !== '')
        .map(repo => ({
          repository: repo.repository,
          repo_gpg_key_url: repo.gpgKeyUrl,
        }))
    );
  }, [repoDataInternal]);

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
    <PageLayout
      header={__('Register Host')}
      searchable={false}
      toolbarButtons={
        <Button
          ouiaId="register-host-documentation-button"
          component="a"
          className="btn-docs"
          href={getDocsURL(
            'Managing_Hosts',
            'registering-a-host_managing-hosts'
          )}
          rel="noreferrer"
          target="_blank"
          variant="secondary"
        >
          {__(' Documentation')}
        </Button>
      }
    >
      <Form
        onSubmit={e => handleSubmit(e)}
        className="registration_commands_form"
        isHorizontal
      >
        <Grid hasGutter>
          <GridItem span={12}>
            <Tabs
              ouiaId="tabs-register-host"
              activeKey={activeTab}
              onSelect={(e, tab) => changeTab(e, tab)}
            >
              <Tab
                ouiaId="tab-general"
                eventKey={0}
                title={<TabTitleText>{__('General')}</TabTitleText>}
                tabContentId="generalTab"
                tabContentRef={generalTabRef}
              />
              <Tab
                ouiaId="tab-advanced"
                eventKey={1}
                title={<TabTitleText>{__('Advanced')}</TabTitleText>}
                tabContentId="advancedTab"
                tabContentRef={advancedTabRef}
              />
            </Tabs>
          </GridItem>

          {apiStatusData === STATUS.ERROR && (
            <>
              <GridItem span={4}>
                <Alert
                  ouiaId="alert-register-host-error"
                  variant="danger"
                  title={__(
                    'There was an error while loading the data, see the logs for more information.'
                  )}
                />
              </GridItem>
              <GridItem span={12} />
            </>
          )}
          <GridItem span={4}>
            <TabContent
              ouiaId="tab-content-register-host-general"
              eventKey={0}
              id="generalSection"
              ref={generalTabRef}
            >
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
                  configParams={configParams}
                  multi
                />
              </div>
            </TabContent>

            <TabContent
              ouiaId="tab-content-register-host-advanced"
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
                  repoData={repoDataInternal}
                  handleRepoData={setRepoDataInternal}
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
                  configParams={configParams}
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
    </PageLayout>
  );
};

export default RegistrationCommandsPage;
