import store from './react_app/redux';
import * as EditorActions from './react_app/components/Editor/EditorActions';

export const initTemplateKind = () => {
  const { value } = document.getElementById(
    'provisioning_template_template_kind_id'
  );
  store.dispatch(EditorActions.changeTemplateKind(value));
};

export const inputOnChange = input => {
  store.dispatch(EditorActions.changeTemplateKind(input.value));
};
