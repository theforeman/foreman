import { translate as __ } from '../../../../../react_app/common/I18n';
import cellFormatter from './cellFormatter';

/* Note: the caller must ensure that the value is extracted for translation */
export default value => cellFormatter(__(value));
