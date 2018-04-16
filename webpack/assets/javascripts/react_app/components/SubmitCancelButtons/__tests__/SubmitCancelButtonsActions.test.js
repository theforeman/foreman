import { onSubmit, onCancel, onMount } from '../SubmitCancelButtonsActions';

describe('SubmitCancelButtons actions', () => {
  it('should on-submit', () => expect(onSubmit()).toMatchSnapshot());
  it('should on-cancel', () => expect(onCancel()).toMatchSnapshot());
  it('should on-mount', () => expect(onMount()).toMatchSnapshot());
});
