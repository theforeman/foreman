import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import ExternalLogout from '../ExternalLogout';
import { props } from '../ExternalLogout.fixtures';

describe('ExternalLogout', () => {
  describe('with all props provided', () => {
    beforeEach(() => {
      render(<ExternalLogout {...props} />);
    });

    it('renders the welcome heading', () => {
      expect(screen.getByRole('heading', { name: /welcome/i })).toBeInTheDocument();
    });

    it('renders the logo image', () => {
      const logo = screen.getByRole('img', { name: 'logo' });
      expect(logo).toHaveAttribute('src', props.logoSrc);
    });

    it('renders the caption when provided', () => {
      expect(screen.getByText(props.caption)).toBeInTheDocument();
    });

    it('renders the login link with correct href', () => {
      const link = screen.getByRole('link', { name: /click to log in again/i });
      expect(link).toHaveAttribute('href', props.submitLink);
    });

    it('applies background image style when backgroundUrl is provided', () => {
      const wrapper = document.querySelector('.external-logout');
      expect(wrapper).toHaveStyle({
        backgroundImage: `url(${props.backgroundUrl})`,
      });
    });
  });

  describe('with optional props omitted', () => {
    it('does not render the caption when not provided', () => {
      const { caption: _caption, ...propsWithoutCaption } = props;
      render(<ExternalLogout {...propsWithoutCaption} />);
      expect(screen.queryByText(props.caption)).not.toBeInTheDocument();
    });

    it('does not apply background image style when backgroundUrl is not provided', () => {
      const { backgroundUrl: _bg, ...propsWithoutBg } = props;
      const { container } = render(<ExternalLogout {...propsWithoutBg} />);
      const wrapper = container.firstChild;
      expect(wrapper.style.backgroundImage).toBe('');
    });
  });
});
