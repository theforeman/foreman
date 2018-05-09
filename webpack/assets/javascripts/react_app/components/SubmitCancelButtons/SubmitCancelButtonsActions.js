import * as consts from './SubmitCancelButtonsConsts';

export const onSubmit = () => ({ type: consts.SUBMIT_CLICKED });
export const onCancel = () => ({ type: consts.CANCEL_CLICKED });
export const onMount = () => ({ type: consts.SUBMIT_AND_CANCEL_RESET });
