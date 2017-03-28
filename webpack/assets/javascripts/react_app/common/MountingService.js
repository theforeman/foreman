import React from 'react';
import StatisticsChartsList from '../components/charts/StatisticsChartsList';
import PowerStatus from '../components/hosts/powerStatus/';
import NotificationDrawerToggle from '../components/notifications/NotificationDrawerToggle';
import NotificationDrawer from '../components/notifications/NotificationDrawer';
import ToastsList from
'../components/notifications/toast/ToastsList';
import ReactDOM from 'react-dom';
import store from '../redux';
export function mount(component, selector, data) {

  const components = {
    StatisticsChartsList: {
      type: StatisticsChartsList,
      markup: <StatisticsChartsList store={store} data={data}/>
    },
    PowerStatus: {
      type: PowerStatus,
      markup: <PowerStatus store={store} data={data}/>
    },
    NotificationDrawerToggle: {
      type: NotificationDrawerToggle,
      markup: <NotificationDrawerToggle url={data.url}/>
    },
    NotificationDrawer: {
      type: NotificationDrawer,
      markup: <NotificationDrawer data={data} />
    },
    ToastNotifications: {
     type: ToastsList,
     markup: <ToastsList store={store} />
   }
  };

  const reactNode = document.querySelector(selector);

  if (reactNode) {
    ReactDOM.render(components[component].markup, reactNode);
  } else {
    const componentName = components[component].type.name;

    // eslint-disable-next-line no-console
    console.log(`Cannot find \'${selector}\' element for mounting the \'${componentName}\'`);
  }
}
