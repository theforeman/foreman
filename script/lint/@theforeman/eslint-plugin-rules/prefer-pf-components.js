const { getStringValue, createClassNameVisitor } = require('./utils');

const CLASS_TO_COMPONENT = {
  'pf-v5-c-alert': 'Alert',
  'pf-v5-c-badge': 'Badge',
  'pf-v5-c-banner': 'Banner',
  'pf-v5-c-brand': 'Brand',
  'pf-v5-c-breadcrumb': 'Breadcrumb',
  'pf-v5-c-button': 'Button',
  'pf-v5-c-card': 'Card',
  'pf-v5-c-check': 'Checkbox',
  'pf-v5-c-chip': 'Chip',
  'pf-v5-c-chip-group': 'ChipGroup',
  'pf-v5-c-clipboard-copy': 'ClipboardCopy',
  'pf-v5-c-code-block': 'CodeBlock',
  'pf-v5-c-context-selector': 'ContextSelector',
  'pf-v5-c-date-picker': 'DatePicker',
  'pf-v5-c-description-list': 'DescriptionList',
  'pf-v5-c-drawer': 'Drawer',
  'pf-v5-c-dropdown': 'Dropdown',
  'pf-v5-c-empty-state': 'EmptyState',
  'pf-v5-c-expandable-section': 'ExpandableSection',
  'pf-v5-c-form': 'Form',
  'pf-v5-c-form-control': 'TextInput / TextArea / FormSelect',
  'pf-v5-c-form-select': 'FormSelect',
  'pf-v5-c-hint': 'Hint',
  'pf-v5-c-icon': 'Icon',
  'pf-v5-c-inline-edit': 'InlineEdit',
  'pf-v5-c-input-group': 'InputGroup',
  'pf-v5-c-label': 'Label',
  'pf-v5-c-label-group': 'LabelGroup',
  'pf-v5-c-list': 'List',
  'pf-v5-c-login': 'LoginPage',
  'pf-v5-c-masthead': 'Masthead',
  'pf-v5-c-menu': 'Menu',
  'pf-v5-c-menu-toggle': 'MenuToggle',
  'pf-v5-c-modal-box': 'Modal',
  'pf-v5-c-nav': 'Nav',
  'pf-v5-c-notification-badge': 'NotificationBadge',
  'pf-v5-c-page': 'Page',
  'pf-v5-c-pagination': 'Pagination',
  'pf-v5-c-panel': 'Panel',
  'pf-v5-c-popover': 'Popover',
  'pf-v5-c-progress': 'Progress',
  'pf-v5-c-radio': 'Radio',
  'pf-v5-c-search-input': 'SearchInput',
  'pf-v5-c-select': 'Select',
  'pf-v5-c-sidebar': 'Sidebar',
  'pf-v5-c-skeleton': 'Skeleton',
  'pf-v5-c-spinner': 'Spinner',
  'pf-v5-c-switch': 'Switch',
  'pf-v5-c-table': 'Table',
  'pf-v5-c-tabs': 'Tabs',
  'pf-v5-c-text-input-group': 'TextInputGroup',
  'pf-v5-c-title': 'Title',
  'pf-v5-c-toggle-group': 'ToggleGroup',
  'pf-v5-c-toolbar': 'Toolbar',
  'pf-v5-c-tooltip': 'Tooltip',
  'pf-v5-c-tree-view': 'TreeView',
  'pf-v5-c-wizard': 'Wizard',
};

const LAYOUT_TO_COMPONENT = {
  'pf-v5-l-flex': 'Flex',
  'pf-v5-l-gallery': 'Gallery',
  'pf-v5-l-grid': 'Grid',
  'pf-v5-l-split': 'Split',
  'pf-v5-l-stack': 'Stack',
  'pf-v5-l-bullseye': 'Bullseye',
  'pf-v5-l-level': 'Level',
};

const PF_CLASS_REGEX = /pf-v5-(?:c|l)-[a-z][a-z0-9-]*/g;

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
