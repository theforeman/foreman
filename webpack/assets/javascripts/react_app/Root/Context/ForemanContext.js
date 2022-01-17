import React from 'react';
import forceSingleton from '../../common/forceSingleton';

export const getForemanContext = contextData =>
  forceSingleton('Context', () => React.createContext(contextData));
export const useForemanContext = () => React.useContext(getForemanContext());

const useForemanMetadata = () => useForemanContext()?.metadata || {};

export const useForemanVersion = () => useForemanMetadata().version;
export const useForemanSettings = () => useForemanMetadata().UISettings;
export const useForemanDocUrl = () => useForemanMetadata().docUrl;
export const useForemanOrganization = () => useForemanMetadata().organization;
export const useForemanLocation = () => useForemanMetadata().location;
export const useForemanUser = () => useForemanMetadata().user;
