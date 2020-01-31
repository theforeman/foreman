import withTour from '../../common/Tour';
import BreadcrumbBar from './';
import { translate as __ } from '../../common/I18n';

const tourConfig = [
  {
    selector: '[data-tut="breadcrumbs_bar"]',
    content: __('Here is the new Breadcumb Bar.'),
  },
  {
    selector: '[data-tut="switcher"]',
    content: __('It offers an easy way to navigate up a level.'),
  },
  {
    selector: '[data-tut="resource-switcher"]',
    content: __(
      'The Breadcrumb Bar Switcher can be used to easily switch to another resource of the same time.'
    ),
  },
];

export default withTour(BreadcrumbBar, tourConfig, 'breadcrumbsTour');
