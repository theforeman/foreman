import React from 'react';
import forceSingleton from '../../common/forceSingleton';

export const getForemanContext = metadata =>
  forceSingleton('Context', () => React.createContext(metadata));
export const useForemanContext = () => React.useContext(getForemanContext());

export const useForemanVersion = () => useForemanContext().version;
export const useForemanSettings = () => useForemanContext().UISettings;
export const useForemanDocUrl = () => useForemanContext().docUrl;
