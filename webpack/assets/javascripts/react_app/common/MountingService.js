import React from 'react';
import StatisticsChartsList from '../components/statistics/StatisticsChartsList';
import PowerStatus from '../components/hosts/powerStatus/';
import NotificationContainer from '../components/notifications/';
import ToastsList from '../components/toastNotifications/';
import PieChart from '../components/common/charts/PieChart/';
import StorageContainer from '../components/hosts/storage/vmware/';
import ReactDOM from 'react-dom';
import store from '../redux';

export function mount(component, selector, data) {
  const components = {
    PieChart: {
      type: PieChart,
      markup: <PieChart data={ data } />
    },
    StatisticsChartsList: {
      type: StatisticsChartsList,
      markup: <StatisticsChartsList store={store} data={data}/>
    },
    PowerStatus: {
      type: PowerStatus,
      markup: <PowerStatus store={store} data={data}/>
    },
    NotificationContainer: {
      type: NotificationContainer,
      markup: <NotificationContainer store={store} data={data} />
    },
    ToastNotifications: {
      type: ToastsList,
      markup: <ToastsList store={store} />
    },
    StorageContainer: {
      type: StorageContainer,
      markup: <StorageContainer store={store} data={data} />
    }
  };

  const reactNode = document.querySelector(selector);

  if (reactNode) {
    ReactDOM.unmountComponentAtNode(reactNode);
    ReactDOM.render(components[component].markup, reactNode);
  } else {
    const componentName = components[component].type.name;

    // eslint-disable-next-line no-console
    console.log(`Cannot find \'${selector}\' element for mounting the \'${componentName}\'`);
  }
}
