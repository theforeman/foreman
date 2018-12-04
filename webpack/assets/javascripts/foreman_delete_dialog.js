import store from './react_app/redux';

import { openDialog } from './react_app/components/DeleteMessageDialog/DeleteMessageDialogActions';

export const confirmDelete = (controller, name, id) => {
  store.dispatch(openDialog(controller, name, id));
};
