import React from 'react';

import App from '../App';
import DonutChart from './common/charts/DonutChart';
import BarChart from './common/charts/BarChart';
import StatisticsChartsList from './statistics/StatisticsChartsList';
import PowerStatus from './hosts/powerStatus/';
import NotificationContainer from './notifications/';
import ToastsList from './toastNotifications/';
import RelativeDateTime from './common/dates/RelativeDateTime';
import LongDateTime from './common/dates/LongDateTime';
import ShortDateTime from './common/dates/ShortDateTime';
import IsoDate from './common/dates/IsoDate';
import StorageContainer from './hosts/storage/vmware/';
import PasswordStrength from './PasswordStrength';
import BreadcrumbBar from './BreadcrumbBar';
import FactChart from './factCharts';
import Pagination from './Pagination/Pagination';
import SearchBar from './SearchBar';
import Layout from './Layout';
import EmptyState from './common/EmptyState';
import ComponentWrapper from './common/ComponentWrapper/ComponentWrapper';
import ChartBox from './statistics/ChartBox';
import ConfigReports from './ConfigReports/ConfigReports';
import DiffModal from './ConfigReports/DiffModal';
import { WrapperFactory } from './wrapperFactory';
import ModelsTable from './ModelsTable';

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
    return Object.values(componentObjs).forEach(obj => this.register(obj));
  },

  getComponent(name) {
    if (!this.registry[name]) {
      throw new Error(
        `Component not found: ${name} among ${this.registeredComponents()}`
      );
    }

    return this.registry[name];
  },

  wrapperFactory() {
    return new WrapperFactory();
  },

  registeredComponents() {
    return Object.keys(this.registry).join(', ');
  },

  defaultWrapper(component, data = null, store = null, flattenData = false) {
    const factory = this.wrapperFactory();

    factory.with('i18n');

    if (store && component.store) {
      factory.with('store', store);
    }
    if (data && component.data) {
      factory.with('data', data, flattenData);
    }
    return factory.wrapper;
  },

  markup(
    name,
    { data = null, store = null, wrapper = null, flattenData = false }
  ) {
    const currentComponent = this.getComponent(name);
    const componentWrapper =
      wrapper ||
      this.defaultWrapper(currentComponent, data, store, flattenData);

    const WrappedComponent = componentWrapper(currentComponent.type);

    return <WrappedComponent />;
  },
};

const coreComponets = [
  { name: 'App', type: App },
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
  { name: 'Layout', type: Layout },
  { name: 'EmptyState', type: EmptyState },
  { name: 'BarChart', type: BarChart },
  { name: 'ChartBox', type: ChartBox },
  { name: 'ComponentWrapper', type: ComponentWrapper },
  { name: 'ConfigReports', type: ConfigReports },
  { name: 'DiffModal', type: DiffModal },
  {
    name: 'RelativeDateTime',
    type: RelativeDateTime,
    data: true,
    store: false,
  },
  {
    name: 'LongDateTime',
    type: LongDateTime,
    data: true,
    store: false,
  },
  {
    name: 'ShortDateTime',
    type: ShortDateTime,
    data: true,
    store: false,
  },
  {
    name: 'IsoDate',
    type: IsoDate,
    data: true,
    store: false,
  },
  { name: 'ModelsTable', type: ModelsTable },
];

componentRegistry.registerMultiple(coreComponets);

export default componentRegistry;
