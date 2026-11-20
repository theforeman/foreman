import { modelErrorToast } from './modelErrorToast';
import { getAPIErrorMessage } from '../../redux/API/APIHelpers';

describe('modelErrorToast', () => {
  it('returns custom message for duplicate model name field errors', () => {
    const error = {
      response: {
        data: {
          error: {
            errors: {
              name: ['has already been taken'],
            },
            full_messages: ['Name has already been taken'],
          },
        },
      },
    };
    const parsedMessage = getAPIErrorMessage(error);

    expect(modelErrorToast(error, parsedMessage)).toBe(
      'A model with this name already exists. Please choose a different name.'
    );
  });

  it('falls back to full_messages pattern matching for duplicate names', () => {
    const error = {
      response: {
        data: {
          error: {
            full_messages: ['Name has already been taken'],
          },
        },
      },
    };
    const parsedMessage = getAPIErrorMessage(error);

    expect(modelErrorToast(error, parsedMessage)).toBe(
      'A model with this name already exists. Please choose a different name.'
    );
  });

  it('returns parsed message for non-duplicate validation errors', () => {
    const error = {
      response: {
        data: {
          error: {
            full_messages: ['Info is too long (maximum is 255 characters)'],
          },
        },
      },
    };
    const parsedMessage = getAPIErrorMessage(error);

    expect(modelErrorToast(error, parsedMessage)).toBe(
      'Info is too long (maximum is 255 characters)'
    );
  });

  it('returns parsedMessage when error has no duplicate name issue', () => {
    const error = {
      response: {
        status: 500,
        data: { error: { message: 'Internal server error' } },
      },
    };
    const parsedMessage = getAPIErrorMessage(error);

    expect(modelErrorToast(error, parsedMessage)).toBe(
      'Internal server error'
    );
  });
});
