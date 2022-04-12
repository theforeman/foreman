import Audits from './Audits';
import Models from './Models';
import HostDetails from './HostDetails';
import RegistrationCommands from './RegistrationCommands';
import HostStatuses from './HostStatuses';
import EmptyPage from './common/EmptyPage/route';
import FiltersForm from './FiltersForm';

export const routes = [
  Audits,
  Models,
  HostDetails,
  RegistrationCommands,
  HostStatuses,
  EmptyPage,
  ...FiltersForm,
];
