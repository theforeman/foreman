import React from 'react';
import forceSingleton from '../common/forceSingleton';

import ReactApp from '../Root/ReactApp';
import DonutChart from './common/charts/DonutChart';
import BarChart from './common/charts/BarChart';
import LineChart from './common/charts/LineChart';
import PowerStatus from './hosts/powerStatus/';
import NotificationContainer from './notifications/';
import ToastsList from './ToastsList/';
import RelativeDateTime from './common/dates/RelativeDateTime';
import LongDateTime from './common/dates/LongDateTime';
import ShortDateTime from './common/dates/ShortDateTime';
import IsoDate from './common/dates/IsoDate';
import FormField from './common/forms/FormField';
import InputFactory from './common/forms/InputFactory';
import StorageContainer from './hosts/storage/vmware/';
import PasswordStrength from './PasswordStrength';
import BreadcrumbBar from './BreadcrumbBar';
import FactChart from './FactCharts';
import Pagination from './Pagination/Pagination';
import AutoComplete from './AutoComplete';
import SearchBar from './SearchBar';
import Layout from './Layout';
import EmptyState from './common/EmptyState';
import ComponentWrapper from './common/ComponentWrapper/ComponentWrapper';
import ChartBox from './ChartBox/ChartBox';
import ConfigReports from './ConfigReports/ConfigReports';
import DiffModal from './ConfigReports/DiffModal';
import { WrapperFactory } from './wrapperFactory';
import ModelsTable from './ModelsTable';
import TemplateGenerator from './TemplateGenerator';
import Editor from './Editor';
import LoginPage from './LoginPage';
import ExternalLogout from './ExternalLogout';
import Slot from './common/Slot';
import TypeAheadSelect from './common/TypeAheadSelect';
import DatePicker from './common/DateTimePicker/DatePicker';
import RedirectCancelButton from './common/RedirectCancelButton';
import SettingRecords from './SettingRecords';
import SettingsTable from './SettingsTable';
import SettingUpdateModal from './SettingUpdateModal';
import PersonalAccessTokens from './users/PersonalAccessTokens';
import ClipboardCopy from './common/ClipboardCopy';
import LabelIcon from './common/LabelIcon';

const componentRegistry = {
  registry: forceSingleton('component_registry', () => ({})),

  register({ name = null, type = null, store = true, data = true }) {
    if (!name || !type) {
      throw new Error('Component name or type is missing');
    }
    if (this.registry[name]) {
      // eslint-disable-next-line no-console
      console.warn(`Component name already taken: ${name}`);
    } else {
      this.registry[name] = { type, store, data };
    }

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
  { name: 'ReactApp', type: ReactApp },
  { name: 'SearchBar', type: SearchBar },
  { name: 'AutoComplete', type: AutoComplete },
  { name: 'DonutChart', type: DonutChart },
  { name: 'LineChart', type: LineChart },
  { name: 'PowerStatus', type: PowerStatus },
  { name: 'NotificationContainer', type: NotificationContainer },
  { name: 'ToastNotifications', type: ToastsList },
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
  { name: 'ExternalLogout', type: ExternalLogout },
  { name: 'Slot', type: Slot },
  { name: 'TypeAheadSelect', type: TypeAheadSelect },
  { name: 'DatePicker', type: DatePicker },
  { name: 'RedirectCancelButton', type: RedirectCancelButton },
  { name: 'SettingRecords', type: SettingRecords },
  { name: 'SettingsTable', type: SettingsTable },
  { name: 'SettingUpdateModal', type: SettingUpdateModal },
  { name: 'PersonalAccessTokens', type: PersonalAccessTokens },
  { name: 'ClipboardCopy', type: ClipboardCopy },
  { name: 'LabelIcon', type: LabelIcon },
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
  { name: 'FormField', type: FormField },
  { name: 'InputFactory', type: InputFactory },
  { name: 'ModelsTable', type: ModelsTable },
  { name: 'Editor', type: Editor },

  // Report templates
  { name: 'TemplateGenerator', type: TemplateGenerator },
  { name: 'LoginPage', type: LoginPage },
];

componentRegistry.registerMultiple(coreComponets);

export default componentRegistry;
