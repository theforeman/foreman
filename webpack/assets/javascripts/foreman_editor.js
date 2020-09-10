import { API } from './react_app/redux/API';
import store from './react_app/redux';

import * as editorActions from './react_app/components/Editor/EditorActions';
import { translate as __ } from './react_app/common/I18n';

export const revertTemplate = async ({ dataset: { version, url } }) => {
  if (
    window.confirm(__('Are you sure you would like to revert the Template?'))
  ) {
    try {
      const response = await API.get(url, {}, { version });
      document.getElementById('primary_tab').click();
      store.dispatch(editorActions.changeEditorValue(response.data));
    } catch (err) {
      alert(__(`Revert Failed, ${err}`));
    }
  }
};
