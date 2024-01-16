import React from 'react';
import forceSingleton from '../../common/forceSingleton';

export const getForemanContext = contextData =>
  forceSingleton('Context', () => React.createContext(contextData));
export const useForemanContext = () =>
  React.useContext(getForemanContext())?.context;
export const useForemanSetContext = () =>
  React.useContext(getForemanContext())?.setContext;

const useForemanMetadata = () => useForemanContext()?.metadata || {};

export const useForemanVersion = () => useForemanMetadata().version;
export const useForemanSettings = () => useForemanMetadata().UISettings;
export const useForemanDocUrl = () => useForemanMetadata().docUrl;
export const useForemanOrganization = () => useForemanMetadata().organization;
export const useForemanLocation = () => useForemanMetadata().location;
export const useForemanUser = () => useForemanMetadata().user;

export const getHostsPageUrl = displayNewHostsPage =>
  displayNewHostsPage ? '/new/hosts' : '/hosts';

export const useForemanHostsPageUrl = () => {
  const { displayNewHostsPage } = useForemanSettings();
  return getHostsPageUrl(displayNewHostsPage);
};
