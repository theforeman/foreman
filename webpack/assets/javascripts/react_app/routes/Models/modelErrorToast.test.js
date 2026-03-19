import { modelErrorToast } from './modelErrorToast';

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

    expect(modelErrorToast(error)).toBe(
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

    expect(modelErrorToast(error)).toBe(
      'A model with this name already exists. Please choose a different name.'
    );
  });

  it('returns full messages for non-duplicate validation errors', () => {
    const error = {
      response: {
        data: {
          error: {
            full_messages: ['Info is too long (maximum is 255 characters)'],
          },
        },
      },
    };

    expect(modelErrorToast(error)).toBe(
      'Info is too long (maximum is 255 characters)'
    );
  });
});
