import React from 'react';
import { Provider } from 'react-redux';
import {
  Form,
  FormGroup,
  FormControl,
  ControlLabel,
  Checkbox,
  Grid,
  Col,
  Row,
  Button,
  Alert,
} from 'patternfly-react';
import store from '../../redux';
import ToastsList, { addToast } from './index';
import Story from '../../../../../stories/components/Story';

export default {
  title: 'Components/Toast Notifications',
};

export const toaster = () => {
  const inputRefs = {};

  const dispatchAddToast = () => {
    const toast = {
      message: inputRefs.message.value,
      type: inputRefs.type.value,
      sticky: inputRefs.sticky.checked,
      timerdelay: Number(inputRefs.timerdelay.value),
    };

    if (inputRefs.showLink.checked) {
      toast.link = {
        href: inputRefs.linkUrl.value,
        children: inputRefs.linkText.value,
      };
    }

    store.dispatch(addToast(toast));
  };

  const setRef = key => ref => {
    inputRefs[key] = ref;
  };

  // eslint-disable-next-line react/prop-types
  const FormField = ({ id, label, children }) => (
    <FormGroup controlId={id}>
      <Col componentClass={ControlLabel} sm={3}>
        {label}
      </Col>
      <Col sm={9}>{React.cloneElement(children, { inputRef: setRef(id) })}</Col>
    </FormGroup>
  );

  const toastCreatorForm = (
    <Form horizontal>
      <FormField id="message" label="Message">
        <FormControl type="text" />
      </FormField>
      <FormField id="type" label="Type">
        <FormControl componentClass="select" type="text">
          {Alert.ALERT_TYPES.map(type => (
            <option key={type} value={type}>
              {type}
            </option>
          ))}
        </FormControl>
      </FormField>
      <FormField id="timerdelay" label="Timer Delay (ms)">
        <FormControl defaultValue={8000} type="number" />
      </FormField>
      <FormField id="sticky">
        <Checkbox>Sticky</Checkbox>
      </FormField>
      <FormField id="showLink">
        <Checkbox>Show Link</Checkbox>
      </FormField>
      <FormField id="linkText" label="Link Text">
        <FormControl type="text" />
      </FormField>
      <FormField id="linkUrl" label="Link URL">
        <FormControl type="url" />
      </FormField>
      <Row>
        <Col sm={9} smOffset={3}>
          <Button onClick={() => dispatchAddToast()}>Create Toast</Button>
        </Col>
      </Row>
    </Form>
  );

  return (
    <Provider store={store}>
      <Story>
        <Grid>
          {toastCreatorForm}
          <ToastsList />
        </Grid>
      </Story>
    </Provider>
  );
};
