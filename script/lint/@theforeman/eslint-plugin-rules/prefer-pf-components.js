const { getStringValue, createClassNameVisitor } = require('./utils');

const CLASS_TO_COMPONENT = {
  'pf-v6-c-alert': 'Alert',
  'pf-v6-c-badge': 'Badge',
  'pf-v6-c-banner': 'Banner',
  'pf-v6-c-brand': 'Brand',
  'pf-v6-c-breadcrumb': 'Breadcrumb',
  'pf-v6-c-button': 'Button',
  'pf-v6-c-card': 'Card',
  'pf-v6-c-check': 'Checkbox',
  'pf-v6-c-chip': 'Chip',
  'pf-v6-c-chip-group': 'ChipGroup',
  'pf-v6-c-clipboard-copy': 'ClipboardCopy',
  'pf-v6-c-code-block': 'CodeBlock',
  'pf-v6-c-context-selector': 'ContextSelector',
  'pf-v6-c-date-picker': 'DatePicker',
  'pf-v6-c-description-list': 'DescriptionList',
  'pf-v6-c-drawer': 'Drawer',
  'pf-v6-c-dropdown': 'Dropdown',
  'pf-v6-c-empty-state': 'EmptyState',
  'pf-v6-c-expandable-section': 'ExpandableSection',
  'pf-v6-c-form': 'Form',
  'pf-v6-c-form-control': 'TextInput / TextArea / FormSelect',
  'pf-v6-c-form-select': 'FormSelect',
  'pf-v6-c-hint': 'Hint',
  'pf-v6-c-icon': 'Icon',
  'pf-v6-c-inline-edit': 'InlineEdit',
  'pf-v6-c-input-group': 'InputGroup',
  'pf-v6-c-label': 'Label',
  'pf-v6-c-label-group': 'LabelGroup',
  'pf-v6-c-list': 'List',
  'pf-v6-c-login': 'LoginPage',
  'pf-v6-c-masthead': 'Masthead',
  'pf-v6-c-menu': 'Menu',
  'pf-v6-c-menu-toggle': 'MenuToggle',
  'pf-v6-c-modal-box': 'Modal',
  'pf-v6-c-nav': 'Nav',
  'pf-v6-c-notification-badge': 'NotificationBadge',
  'pf-v6-c-page': 'Page',
  'pf-v6-c-pagination': 'Pagination',
  'pf-v6-c-panel': 'Panel',
  'pf-v6-c-popover': 'Popover',
  'pf-v6-c-progress': 'Progress',
  'pf-v6-c-radio': 'Radio',
  'pf-v6-c-search-input': 'SearchInput',
  'pf-v6-c-select': 'Select',
  'pf-v6-c-sidebar': 'Sidebar',
  'pf-v6-c-skeleton': 'Skeleton',
  'pf-v6-c-spinner': 'Spinner',
  'pf-v6-c-switch': 'Switch',
  'pf-v6-c-table': 'Table',
  'pf-v6-c-tabs': 'Tabs',
  'pf-v6-c-text-input-group': 'TextInputGroup',
  'pf-v6-c-title': 'Title',
  'pf-v6-c-toggle-group': 'ToggleGroup',
  'pf-v6-c-toolbar': 'Toolbar',
  'pf-v6-c-tooltip': 'Tooltip',
  'pf-v6-c-tree-view': 'TreeView',
  'pf-v6-c-wizard': 'Wizard',
};

const LAYOUT_TO_COMPONENT = {
  'pf-v6-l-flex': 'Flex',
  'pf-v6-l-gallery': 'Gallery',
  'pf-v6-l-grid': 'Grid',
  'pf-v6-l-split': 'Split',
  'pf-v6-l-stack': 'Stack',
  'pf-v6-l-bullseye': 'Bullseye',
  'pf-v6-l-level': 'Level',
};

const PF_CLASS_REGEX = /pf-v6-(?:c|l)-[a-z][a-z0-9-]*/g;

function extractClassNames(value) {
  if (!value || typeof value !== 'string') return [];
  const matches = value.match(PF_CLASS_REGEX);
  return matches || [];
}

function getBaseClass(className) {
  const parts = className.split('__');
  return parts[0];
}

function findMatchingComponent(pfClass) {
  const baseClass = getBaseClass(pfClass);
  return CLASS_TO_COMPONENT[baseClass] || LAYOUT_TO_COMPONENT[baseClass];
}

module.exports = {
  meta: {
    type: 'suggestion',
    docs: {
      description:
        'Prefer PatternFly React components over raw PatternFly CSS class names in JSX',
    },
    schema: [],
  },
  create(context) {
    function checkForPfClasses(node, valueNode) {
      const stringValue = getStringValue(valueNode);
      if (!stringValue) return;

      const pfClasses = extractClassNames(stringValue);
      const reported = new Set();

      pfClasses.forEach(pfClass => {
        if (reported.has(pfClass)) return;

        reported.add(pfClass);

        const component = findMatchingComponent(pfClass);
        const message = component
          ? `Prefer using the <${component}> component instead of the '${pfClass}' CSS class.`
          : `Avoid using the '${pfClass}' CSS class directly; use the equivalent PatternFly React component instead.`;

        context.report({ node, message });
      });
    }

    return createClassNameVisitor(checkForPfClasses);
  },
};
