import HostWizard from './HostWizard';
import Statistics from './Statistics';
import Audits from './Audits';

export const routes = [HostWizard, Statistics, Audits];

export const routesPath = routes.map(route => route.path);
