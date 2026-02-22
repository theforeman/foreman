import TextField from './TextField';
import { deprecate } from '../../../../common/DeprecationService';

deprecate(
  'forms/TextField',
  'TextInput/TextArea from @patternfly/react-core',
  '3.21'
);
export default TextField;
