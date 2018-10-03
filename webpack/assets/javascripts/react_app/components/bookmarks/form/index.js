import React from 'react';
import { reduxForm } from 'redux-form';
import { connect } from 'react-redux';
import { required, length } from 'redux-form-validators';
import Form from '../../common/forms/Form';
import TextField from '../../common/forms/TextField';
import * as FormActions from '../../../redux/actions/common/forms';

const submit = ({ name, query, publik }, dispatch, props) => {
  const { submitForm, url, controller } = props;
  const values = {
    name,
    query,
    public: publik || false,
    controller,
  };

  return submitForm({ url, values, item: 'Bookmark' });
};

class BookmarkForm extends React.Component {
  render() {
    const { handleSubmit, submitting, error, onCancel } = this.props;

    return (
      <Form
        onSubmit={handleSubmit(submit)}
        onCancel={onCancel}
        disabled={submitting}
        submitting={submitting}
        error={error}
      >
        <TextField
          name="name"
          type="text"
          required="true"
          label={__('Name')}
          validate={[required(), length({ max: 254 })]}
        />
        <TextField
          name="query"
          type="textarea"
          required="true"
          label={__('Query')}
          inputClassName="col-md-8"
          validate={[required(), length({ max: 4096 })]}
        />
        <TextField name="publik" type="checkbox" label={__('Public')} />
      </Form>
    );
  }
}

const form = reduxForm({
  form: 'bookmark',
})(BookmarkForm);

export default connect(
  ({ bookmarks }) => ({
    initialValues: { publik: true, query: bookmarks.currentQuery || '' },
  }),
  FormActions
)(form);
