import { deprecate } from '../../../../common/DeprecationService';

let columnDeprecationLogged = false;

const logColumnDeprecation = () => {
  if (columnDeprecationLogged) {
    return;
  }

  columnDeprecationLogged = true;
  deprecate(
    'table/schemaHelpers/column',
    'TableIndexPage from foremanReact/components/PF4/TableIndexPage/TableIndexPage or Table from @patternfly/react-table',
    '5.2'
  );
};

/**
 * Generate a column for a patternfly-3 table.
 * See more in http://patternfly-react.surge.sh/patternfly-3/
 * See an example: components SettingsTableSchema.js
 * @param  {String} property  the property name of the table.
 * @param  {String} label     the column label.
 * @param  {Array} headFormat array of functions that format the header. Read more about format
 *                            functions here:
 *                            https://reactabular.js.org/#/column-definition/formatters
 * @param  {Array} cellFormat array of functions that format column cells. Read more about format
 *                            functions here:
 *                            https://reactabular.js.org/#/column-definition/formatters
 * @param  {Object} headProps React props that can be passed to the header.
 * @param  {Object} cellProps React props that can be passed to cells.
 * @return {Object} the table column.
 */
export const column = (
  property,
  label,
  headFormat,
  cellFormat,
  headProps = {},
  cellProps = {}
) => {
  logColumnDeprecation();

  return {
    property,
    header: {
      label,
      props: headProps,
      formatters: headFormat,
    },
    cell: {
      props: cellProps,
      formatters: cellFormat,
    },
  };
};
