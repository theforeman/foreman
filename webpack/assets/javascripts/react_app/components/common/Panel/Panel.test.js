jest.unmock('./Panel');

import React from 'react';
import {mount, shallow} from 'enzyme';
import Panel from './Panel';
import PanelHeading from './PanelHeading';
import PanelTitle from './PanelTitle';
import PanelBody from './PanelBody';
import PanelFooter from './PanelFooter';

function mountPanel(type) {
  return mount(
    <Panel type={type || ''}>
    <PanelHeading>
      <PanelTitle text="Title"></PanelTitle>
    </PanelHeading>
    <PanelBody>
      <ul>
        <li>1</li>
        <li>2</li>
        <li>3</li>
      </ul>
    </PanelBody>
    <PanelFooter>
      This is the footer
    </PanelFooter>
  </Panel>);
}

describe('Panel', () => {
  describe('Panel and composition', () => {
    function getPanel(type) {
      return shallow(
        <Panel type={type || ''}>
          <PanelBody></PanelBody>
        </Panel>);
    }

    it('Panel composition', () => {
      const wrapper = mountPanel();

      expect(wrapper.children().length).toBe(3);
    });
    it('Panel component', () => {
      const wrapper = getPanel();

      expect(wrapper.is('.panel.panel-default')).toBe(true);
    });
    it('handles type specification correctly', () => {
      const wrapper = getPanel('danger');

      expect(wrapper.is('.panel.panel-danger')).toBe(true);
    });
  });

  describe('PanelHeading', () => {
    function getHeading() {
      return shallow(
        <PanelHeading>
          <PanelTitle text="Title"></PanelTitle>
        </PanelHeading>);
    }

    it('has children', () => {
      const heading = getHeading();

      expect(heading.children().length).toBe(1);
    });
    it('is styled correctly', () => {
      const heading = getHeading();

      expect(heading.is('.panel-heading')).toBe(true);
    });
  });

  describe('PanelTitle', () => {
    function getTitle() {
      return shallow(
        <PanelTitle text="Title"></PanelTitle>
      );
    }

    it('renders correct text', () => {
      const title = getTitle();

      expect(title.text()).toBe('Title');
    });

    it('is styled correctly', () => {
      const title = getTitle();

      expect(title.is('.panel-title')).toBe(true);
    });
  });

  describe('PanelBody', () => {
    function getBody() {
      return shallow(
        <PanelBody>
          <ul>
            <li>1</li>
            <li>2</li>
            <li>3</li>
          </ul>
        </PanelBody>
      );
    }

    it('has 1 child and 3 grandchildren', () => {
      const body = getBody();

      expect(body.children().length).toBe(1);
      expect(body.childAt(0).children().length).toBe(3);
    });
    it('is styled correctly', () => {
      const body = getBody();

      expect(body.is('.panel-body')).toBe(true);
    });
  });

  describe('PanelFooter', () => {
    function getFooter() {
      return shallow(
        <PanelFooter>
          This is the footer
        </PanelFooter>
      );
    }

    it('renders correct text', () => {
      const footer = getFooter();

      expect(footer.text()).toBe('This is the footer');
    });
    it('has no children', () => {
      const footer = getFooter();

      expect(footer.children().length).toBe(1);
      expect(footer.childAt(0).node).toBe('This is the footer');
    });
    it('is styled correctly', () => {
      const footer = getFooter();

      expect(footer.is('.panel-footer')).toBe(true);
    });
  });
});
