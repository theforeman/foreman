import { deprecate } from '../../../common/DeprecationService';

deprecate('import from redux/action/toasts', 'components/ToastsList', '3.2');

export {
  addToast,
  deleteToast,
  clearToasts,
} from '../../../components/ToastsList';
