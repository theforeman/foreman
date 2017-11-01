import React from 'react';
import PieChart from './common/charts/PieChart/';
import StatisticsChartsList from './statistics/StatisticsChartsList';
import PowerStatus from './hosts/powerStatus/';
import NotificationContainer from './notifications/';
import ToastsList from './toastNotifications/';
import StorageContainer from './hosts/storage/vmware/';
import forEach from 'lodash/forEach';
import map from 'lodash/map';

const componentRegistry = {
  registry: {},

  register({ name = null, type = null, store = true, data = true }) {
    if (!name || !type) {
      throw new Error('Component name or type is missing');
    }
    if (this.registry[name]) {
      throw new Error(`Component name already taken: ${name}`);
    }

    this.registry[name] = { type, store, data };
    return this.registry;
  },

  registerMultiple(componentObjs) {
    return forEach(componentObjs, obj => {
      return this.register(obj);
    });
  },

  getComponent(name) {
    return this.registry[name];
  },

  registeredComponents() {
    return map(this.registry, (value, key) => {
      return key;
    }).join(', ');
  },

  markup(name, data, store) {
    const currentComponent = this.getComponent(name);

    if (!currentComponent) {
      throw new Error(
        `Component not found:  ${name} among ${this.registeredComponents()}`
      );
    }
    const ComponentName = currentComponent.type;

    return (
      <ComponentName
        data={currentComponent.data ? data : undefined}
        store={currentComponent.store ? store : undefined}
      />
    );
  },
};

const coreComponets = [
  { name: 'PieChart', type: PieChart },
  { name: 'StatisticsChartsList', type: StatisticsChartsList },
  { name: 'PowerStatus', type: PowerStatus },
  { name: 'NotificationContainer', type: NotificationContainer },
  { name: 'ToastNotifications', type: ToastsList, data: false },
  { name: 'StorageContainer', type: StorageContainer },
];

componentRegistry.registerMultiple(coreComponets);

export default componentRegistry;
