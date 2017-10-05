import React from 'react';
import forEach from 'lodash/forEach';
import map from 'lodash/map';
import PieChart from './common/charts/PieChart/';
import StatisticsChartsList from './statistics/StatisticsChartsList';
import PowerStatus from './hosts/powerStatus/';
import NotificationContainer from './notifications/';
import ToastsList from './toastNotifications/';
import RelativeDateTime from './common/dates/RelativeDateTime';
import LongDateTime from './common/dates/LongDateTime';
import ShortDateTime from './common/dates/ShortDateTime';
import Date from './common/dates/Date';
import StorageContainer from './hosts/storage/vmware/';
import { WrapperFactory } from './wrapperFactory';

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
    return forEach(componentObjs, obj => this.register(obj));
  },

  getComponent(name) {
    if (!this.registry[name]) {
      throw new Error(`Component not found: ${name} among ${this.registeredComponents()}`);
    }

    return this.registry[name];
  },

  wrapperFactory() {
    return new WrapperFactory();
  },

  registeredComponents() {
    return map(this.registry, (value, key) => key).join(', ');
  },

  defaultWrapper(component, data = null, store = null) {
    const factory = new WrapperFactory();

    factory.with('intl');

    if (store && component.store) {
      factory.with('store', store);
    }
    if (data && component.data) {
      factory.with('data', data);
    }
    return factory.wrapper;
  },

  markup(name, { data = null, store = null, wrapper = null }) {
    const currentComponent = this.getComponent(name);
    const componentWrapper = wrapper || this.defaultWrapper(currentComponent, data, store);

    const ComponentName = componentWrapper(currentComponent.type);

    return (<ComponentName />);
  },
};

const coreComponets = [
  { name: 'PieChart', type: PieChart },
  { name: 'StatisticsChartsList', type: StatisticsChartsList },
  { name: 'PowerStatus', type: PowerStatus },
  { name: 'NotificationContainer', type: NotificationContainer },
  { name: 'ToastNotifications', type: ToastsList, data: false },
  { name: 'StorageContainer', type: StorageContainer },
  {
    name: 'RelativeDateTime', type: RelativeDateTime, data: true, store: false,
  },
  {
    name: 'LongDateTime', type: LongDateTime, data: true, store: false,
  },
  {
    name: 'ShortDateTime', type: ShortDateTime, data: true, store: false,
  },
  {
    name: 'Date', type: Date, data: true, store: false,
  },
];

componentRegistry.registerMultiple(coreComponets);

export default componentRegistry;
