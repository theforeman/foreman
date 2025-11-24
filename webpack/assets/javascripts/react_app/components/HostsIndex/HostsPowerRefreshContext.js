import React from 'react';

export const HostsPowerRefreshContext = React.createContext({
  refreshId: 0,
  bumpRefresh: () => {},
});
