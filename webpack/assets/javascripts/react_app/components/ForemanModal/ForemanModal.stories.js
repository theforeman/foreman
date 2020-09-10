import React from 'react';
import { Button } from 'patternfly-react';
import storeDecorator from '../../../../../stories/storeDecorator';
import ForemanModal from '.';
import { useForemanModal } from './ForemanModalHooks';
import Story from '../../../../../stories/components/Story';

export default {
  title: 'Components|ForemanModal/Props & Children',
  decorators: [storeDecorator],
};

export const withDefaultHeaderFooter = () =>
  // using createElement here so that hooks work in stories
  React.createElement(() => {
    const { setModalOpen } = useForemanModal({ id: 'default' });
    return (
      <Story>
        <Button bsStyle="primary" onClick={setModalOpen}>
          Show Modal
        </Button>
        <ForemanModal id="default" title="I'm a modal!">
          <ForemanModal.Header />
          If you supply a title prop, it will be used as the modal title.
          <ForemanModal.Footer />
        </ForemanModal>
      </Story>
    );
  });

withDefaultHeaderFooter.story = {
  name: 'With default header & footer',
};

export const withNoChildren = () =>
  // using createElement here so that hooks work in stories
  React.createElement(() => {
    const { setModalOpen } = useForemanModal({ id: 'noChildren' });
    return (
      <Story>
        <Button bsStyle="primary" onClick={setModalOpen}>
          Show Modal
        </Button>
        <ForemanModal id="noChildren" title="I'm a modal!" />
      </Story>
    );
  });

withNoChildren.story = {
  name: 'With no children',
};

export const withCustomHeaderFooter = () =>
  React.createElement(() => {
    const { setModalOpen } = useForemanModal({ id: 'custom' });
    return (
      <Story>
        <Button bsStyle="primary" onClick={setModalOpen}>
          Show Modal
        </Button>
        <ForemanModal id="custom">
          <ForemanModal.Header>
            <h3>This is a custom header! :)</h3>
          </ForemanModal.Header>
          You can provide your own {`<ForemanModal.Header>`}
          <ForemanModal.Footer>
            Click the X in the upper right to close
          </ForemanModal.Footer>
        </ForemanModal>
      </Story>
    );
  });

withCustomHeaderFooter.story = {
  name: 'With custom header & footer',
};

export const withUnorderedHeaderFooter = () =>
  React.createElement(() => {
    const { setModalOpen } = useForemanModal({ id: 'unordered' });
    return (
      <Story>
        <Button bsStyle="primary" onClick={setModalOpen}>
          Show Modal
        </Button>
        <ForemanModal id="unordered" title="I'm a custom modal!">
          <div>
            Header and footer will be correctly ordered when rendering, even if
            they are out of order in the markup
          </div>
          <ForemanModal.Footer>This is the footer</ForemanModal.Footer>
          <ForemanModal.Header>
            <h3>This is the header</h3>
          </ForemanModal.Header>
        </ForemanModal>
      </Story>
    );
  });

withUnorderedHeaderFooter.story = {
  name: 'With unordered header & footer',
};

export const withNoCloseButton = () =>
  React.createElement(() => {
    const { setModalOpen } = useForemanModal({ id: 'noClose' });
    return (
      <Story>
        <Button bsStyle="primary" onClick={setModalOpen}>
          Show Modal
        </Button>
        <ForemanModal id="noClose" title="I'm an X-less modal!">
          <ForemanModal.Header closeButton={false} />
          <br />
          Props passed to ForemanModal.Header will be passed down to
          Modal.Header
          <ForemanModal.Footer />
        </ForemanModal>
      </Story>
    );
  });

withNoCloseButton.story = {
  name: 'With no close button',
};

export const withNoFooter = () =>
  React.createElement(() => {
    const { setModalOpen } = useForemanModal({ id: 'noFooter' });
    return (
      <Story>
        <Button bsStyle="primary" onClick={setModalOpen}>
          Show Modal
        </Button>
        <ForemanModal id="noFooter" title="I'm a modal!">
          <ForemanModal.Header />
          This is the modal body. There is no footer.
        </ForemanModal>
      </Story>
    );
  });

withNoFooter.story = {
  name: 'With no footer',
};

export const withNoHeader = () =>
  React.createElement(() => {
    const { setModalOpen } = useForemanModal({ id: 'noHeader' });
    return (
      <Story>
        <Button bsStyle="primary" onClick={setModalOpen}>
          Show Modal
        </Button>
        <ForemanModal id="noHeader">
          If neither a {`<ForemanModal.Header>`} nor a title prop are supplied,{' '}
          <br />
          the modal will have no header.
          <ForemanModal.Footer />
        </ForemanModal>
      </Story>
    );
  });

withNoHeader.story = {
  name: 'With no header',
};

export const withPropsPassedDownViaSpreadSyntax = () =>
  React.createElement(() => {
    const { setModalOpen } = useForemanModal({ id: 'propsPassed' });
    return (
      <Story>
        <Button bsStyle="primary" onClick={setModalOpen}>
          Show Modal
        </Button>
        <ForemanModal id="propsPassed" title="I'm a modal!" myProp="Hii">
          <ForemanModal.Header />
          The inner {`<Modal>`} component will have any props you pass to
          {`<ForemanModal>`}. (Look in the React dev tools for
          &lsquo;myProp&rsquo;)
          <ForemanModal.Footer />
        </ForemanModal>
      </Story>
    );
  });

withPropsPassedDownViaSpreadSyntax.story = {
  name: 'With props passed down via spread syntax',
};
