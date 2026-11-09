import { translate as __ } from '../../../../../react_app/common/I18n';
import cellFormatter from './cellFormatter';
import { deprecate } from '../../../../common/DeprecationService';

let translatedCellFormatterDeprecationLogged = false;

const logTranslatedCellFormatterDeprecation = () => {
  if (translatedCellFormatterDeprecationLogged) {
    return;
  }

  translatedCellFormatterDeprecationLogged = true;
  deprecate(
    'table/formatters/translatedCellFormatter',
    'TableIndexPage from foremanReact/components/PF4/TableIndexPage/TableIndexPage or Table from @patternfly/react-table',
    '5.2'
  );
};

/* Note: the caller must ensure that the value is extracted for translation */
export default value => {
  logTranslatedCellFormatterDeprecation();

  return cellFormatter(__(value));
};
