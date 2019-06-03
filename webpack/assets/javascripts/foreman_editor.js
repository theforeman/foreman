import API from './react_app/API';
import store from './react_app/redux';

import * as editorActions from './react_app/components/Editor/EditorActions';
import { translate as __ } from './react_app/common/I18n';

export const revertTemplate = ({ dataset: { version, url } }) => {
  if (
    window.confirm(__('Are you sure you would like to revert the Template?'))
  ) {
    API.get(url, {}, { version })
      .then(res => {
        document.getElementById('primary_tab').click();
        store.dispatch(editorActions.changeEditorValue(res.data));
      })
      .catch(res => {
        alert(__(`Revert Failed, ${res}`));
      });
  }
};
