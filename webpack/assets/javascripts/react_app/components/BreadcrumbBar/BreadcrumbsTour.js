import withTour from '../../common/Tour';
import BreadcrumbBar from './';
import { translate as __ } from '../../common/I18n';

const tourConfig = [
  {
    selector: '[data-tut="breadcrumbs_bar"]',
    content: __('Welcome the new Breadcrumbs bar navigation !'),
  },
  {
    selector: '[data-tut="switcher"]',
    content: __('Easy way to naviage back'),
  },
  {
    selector: '[data-tut="resource-switcher"]',
    content: __(
      'Switching to another resource is now super fast, with the new Resource Switcher!'
    ),
  },
];

export default withTour(BreadcrumbBar, tourConfig, 'breadcrumbsTour');
