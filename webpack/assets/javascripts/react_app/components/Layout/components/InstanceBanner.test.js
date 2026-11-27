import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import { InstanceBanner } from './InstanceBanner';

describe('InstanceBanner', () => {
  it('renders nothing without an instance title', () => {
    const { container } = render(<InstanceBanner data={{}} />);
    expect(container).toBeEmptyDOMElement();
  });

  it('applies the instance color through the PF6 banner variable', () => {
    const { container } = render(
      <InstanceBanner
        data={{ instance_title: 'Production', instance_color: '#ffcc00' }}
      />
    );
    expect(screen.getByText('Production')).toBeInTheDocument();
    const banner = container.querySelector('.instance-banner');
    expect(
      banner.style.getPropertyValue('--pf-v6-c-banner--BackgroundColor')
    ).toBe('#ffcc00');
  });

  it('picks a readable text color for the background', () => {
    render(
      <InstanceBanner
        data={{ instance_title: 'Dark', instance_color: '#000033' }}
      />
    );
    expect(screen.getByText('Dark')).toHaveStyle({ color: 'white' });
  });

  it('falls back to black for an invalid color', () => {
    const { container } = render(
      <InstanceBanner
        data={{ instance_title: 'Bad', instance_color: 'not-a-color' }}
      />
    );
    expect(
      container
        .querySelector('.instance-banner')
        .style.getPropertyValue('--pf-v6-c-banner--BackgroundColor')
    ).toBe('#000000');
  });
});
