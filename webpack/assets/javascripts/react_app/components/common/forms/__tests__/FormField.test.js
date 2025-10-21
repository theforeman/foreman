import React from 'react';
import { screen, fireEvent, render, act } from '@testing-library/react';
import '@testing-library/jest-dom/extend-expect';

import {
  dateTimeWithErrorProps,
  textFieldWithHelpProps,
  formAutocompleteDataProps,
} from '../FormField.fixtures';
import FormField from '../FormField';

const fixtures = {
  'renders text input': { type: 'text', name: 'a' },
  'renders Date input': { type: 'date', name: 'a' },
  'renders Time input': { type: 'time', name: 'a' },
  'renders DateTime input': { type: 'dateTime', name: 'a' },
  'renders text complex options and help': textFieldWithHelpProps,
  'renders DateTime complex options and error': dateTimeWithErrorProps,
  'renders AutoComplete': { type: 'autocomplete', formAutocompleteDataProps },
};

describe('FormField', () => {
  describe('rendering', () => {
    it('renders text input', () => {
      const { container } = render(<FormField {...fixtures['renders text input']} />);
      expect(container.querySelector('input[type="text"]')).toBeInTheDocument();
    });

    it('renders Date input', () => {
      const { container } = render(<FormField {...fixtures['renders Date input']} />);
      expect(container.querySelector('input[aria-label="date-time-picker-input"]')).toBeInTheDocument();
    });

    it('renders Time input', () => {
      const { container } = render(<FormField {...fixtures['renders Time input']} />);
      expect(container.querySelector('input[aria-label="date-time-picker-input"]')).toBeInTheDocument();
    })

    it('renders DateTime input', () => {
      const { container } = render(<FormField {...fixtures['renders DateTime input']} />);
      expect(container.querySelector('input[aria-label="date-picker-input"]')).toBeInTheDocument();
    })

    it('renders text complex options and help', () => {
      const { container } = render(<FormField {...fixtures['renders text complex options and help']} />);
      expect(container.querySelector('input[name="group[textfield]"]')).toBeInTheDocument();
    })

    it('renders DateTime complex options and error', () => {
      render(<FormField {...fixtures['renders DateTime complex options and error']} />);
      expect(screen.getByLabelText('DateTime with error')).toBeInTheDocument();
    })

    xit('renders AutoComplete', () => { // skipping since already updated in another test
      render(<FormField {...fixtures['renders AutoComplete']} />);
    })
  })
})
