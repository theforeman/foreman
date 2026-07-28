const getProp = require('jsx-ast-utils/getProp');

module.exports = {
  create(context) {
    const patternflyImports = new Set();
    const defaults = [
      'Alert',
      'Breadcrumb',
      'Button',
      'Card',
      'Checkbox',
      'Chip',
      'ChipGroup',
      'ClipboardCopy',
      'ContextSelector',
      'Dropdown',
      'DropdownItem',
      'DropdownSeparator',
      'DropdownToggle',
      'DropdownToggleCheckbox',
      'FormSelect',
      'Menu',
      'MenuToggle',
      'Modal',
      'ModalBoxCloseButton',
      'ModalContent',
      'Nav',
      'NavExpandable',
      'NavItem',
      'OptionsMenu',
      'Pagination',
      'Radio',
      'RowWrapper',
      'Select',
      'Switch',
      'Tab',
      'TabButton',
      'TabContent',
      'Table',
      'TableComposable',
      'Tabs',
      'Text',
      'TextInput',
      'Title',
      'Toolbar',
      'Tr',
    ];

    const { additional } =
      (context.options.length === 1 && context.options[0]) || {};
    const { options: contextOptions } = context;

    let options = defaults;
    if (additional) {
      options = [...defaults, ...additional];
    } else if (contextOptions.length) {
      options = contextOptions;
    }

    function addPatternflyImport(node) {
      if (
        node.type === 'ImportDeclaration' &&
        node.source.value.startsWith('@patternfly/react')
      ) {
        node.specifiers.forEach(specifier => {
          if (specifier.type === 'ImportSpecifier') {
            patternflyImports.add(specifier.local.name);
          }
        });
      }
    }

    function checkPatternflyComponent(node) {
      if (!options.includes(node.name.name)) {
        return;
      }
      if (
        node.type === 'JSXOpeningElement' &&
        patternflyImports.has(node.name.name)
      ) {
        const ouiaIdProp = getProp(node.attributes, 'ouiaId');
        if (!ouiaIdProp) {
          context.report({
            node,
            message: `ouiaId property is missing in PatternFly component '${node.name.name}'`,
          });
        }
      }
    }
    return {
      ImportDeclaration: addPatternflyImport,
      JSXOpeningElement: checkPatternflyComponent,
    };
  },
};
