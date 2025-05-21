const getProp = require('jsx-ast-utils/getProp');

module.exports = {
  create(context) {
    const patternflyImports = new Set();
    const options = context.options.length
      ? context.options
      : [
          'Alert',
          'Breadcrumb',
          'Button',
          'Card',
          'Checkbox',
          'Chip',
          'ChipGroup',
          'ContextSelector',
          'Dropdown',
          'DropdownItem',
          'DropdownSeparator',
          'DropdownToggle',
          'DropdownToggleCheckbox',
          'FormSelect',
          'Menu',
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
          'TabButton',
          'TabContent',
          'Tab',
          'Tabs',
          'Text',
          'TextInput',
          'Title',
          'Toolbar',
          'Table',
          'TableComposable',
          'Tr',
        ];

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
