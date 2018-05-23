import React from 'react';

import DonutChart from './common/charts/DonutChart';
import BarChart from './common/charts/BarChart';
import StatisticsChartsList from './statistics/StatisticsChartsList';
import PowerStatus from './hosts/powerStatus/';
import NotificationContainer from './notifications/';
import ToastsList from './toastNotifications/';
import StorageContainer from './hosts/storage/vmware/';
import PasswordStrength from './PasswordStrength';
import BreadcrumbBar from './BreadcrumbBar';
import FactChart from './factCharts';
import Pagination from './Pagination/Pagination';
import AuditsList from './AuditsList';
import SearchBar from './SearchBar';
import Layout from './Layout';
import EmptyState from './common/EmptyState';
import ComponentWrapper from './common/ComponentWrapper/ComponentWrapper';
import ChartBox from './statistics/ChartBox';
import ConfigReports from './ConfigReports/ConfigReports';

const componentRegistry = {
  registry: {},

  register({
    name = null, type = null, store = true, data = true,
  }) {
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
    return Object.values(componentObjs).forEach(obj => this.register(obj));
  },

  getComponent(name) {
    return this.registry[name];
  },

  registeredComponents() {
    return Object.keys(this.registry).join(', ');
  },

  markup(name, data, store, flattenData) {
    const currentComponent = this.getComponent(name);

    if (!currentComponent) {
      throw new Error(`Component not found:  ${name} among ${this.registeredComponents()}`);
    }
    const ComponentName = currentComponent.type;

    if (flattenData) {
      return (
        <ComponentName
          store={currentComponent.store ? store : undefined}
          { ...data }
        />
      );
    }
    return (
      <ComponentName
        data={currentComponent.data ? data : undefined}
        store={currentComponent.store ? store : undefined}
      />
    );
  },
};

const coreComponets = [
  { name: 'SearchBar', type: SearchBar },
  { name: 'DonutChart', type: DonutChart },
  { name: 'StatisticsChartsList', type: StatisticsChartsList },
  { name: 'PowerStatus', type: PowerStatus },
  { name: 'NotificationContainer', type: NotificationContainer },
  { name: 'ToastNotifications', type: ToastsList, data: false },
  { name: 'StorageContainer', type: StorageContainer },
  { name: 'PasswordStrength', type: PasswordStrength },
  { name: 'BreadcrumbBar', type: BreadcrumbBar },
  { name: 'FactChart', type: FactChart },
  { name: 'Pagination', type: Pagination },
  { name: 'AuditsList', type: AuditsList },
  { name: 'Layout', type: Layout },
  { name: 'EmptyState', type: EmptyState },
  { name: 'BarChart', type: BarChart },
  { name: 'ChartBox', type: ChartBox },
  { name: 'ComponentWrapper', type: ComponentWrapper },
  { name: 'ConfigReports', type: ConfigReports },
];

componentRegistry.registerMultiple(coreComponets);

export default componentRegistry;
