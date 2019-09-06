import React, { useState } from 'react';
import { Button } from 'patternfly-react';
import { storiesOf } from '@storybook/react';
import ForemanModal from '.';
import Story from '../../../../../stories/components/Story';

// This custom Hook is only for the Storybook
const useModalState = initialModalState => {
  const [modalOpen, setModalOpen] = useState(initialModalState);
  const toggleModal = () => setModalOpen(!modalOpen);
  return [modalOpen, toggleModal];
};

storiesOf('Components/ForemanModal', module).add(
  'With default header & footer',
  () =>
    // using createElement here so that hooks work in stories
    React.createElement(() => {
      const [modalOpen, toggleModal] = useModalState(false);
      return (
        <Story>
          <Button bsStyle="primary" onClick={toggleModal}>
            Show Modal
          </Button>
          <ForemanModal
            isOpen={modalOpen}
            title="I'm a modal!"
            onClose={toggleModal}
          >
            <ForemanModal.Header />
            This is the modal body
            <ForemanModal.Footer />
          </ForemanModal>
        </Story>
      );
    })
);

storiesOf('Components/ForemanModal', module).add(
  'With custom header & footer',
  () =>
    React.createElement(() => {
      const [modalOpen, toggleModal] = useModalState(false);
      return (
        <Story>
          <Button bsStyle="primary" onClick={toggleModal}>
            Show Modal
          </Button>
          <ForemanModal
            isOpen={modalOpen}
            title="I'm a custom modal!"
            onClose={toggleModal}
          >
            <ForemanModal.Header>
              <h3>This is a custom header! :)</h3>
            </ForemanModal.Header>
            If a {`<ForemanModal.Header>`} is provided AND has children, the
            title prop will be ignored.
            <ForemanModal.Footer>
              Click the X in the upper right to close
            </ForemanModal.Footer>
          </ForemanModal>
        </Story>
      );
    })
);

storiesOf('Components/ForemanModal', module).add('With no close button', () =>
  React.createElement(() => {
    const [modalOpen, toggleModal] = useModalState(false);
    return (
      <Story>
        <Button bsStyle="primary" onClick={toggleModal}>
          Show Modal
        </Button>
        <ForemanModal
          isOpen={modalOpen}
          title="I'm an X-less modal!"
          onClose={toggleModal}
        >
          <ForemanModal.Header closeButton={false} />
          <br />
          Props passed to ForemanModal.Header will be passed down to
          Modal.Header
          <ForemanModal.Footer />
        </ForemanModal>
      </Story>
    );
  })
);

storiesOf('Components/ForemanModal', module).add('With no footer', () =>
  React.createElement(() => {
    const [modalOpen, toggleModal] = useModalState(false);
    return (
      <Story>
        <Button bsStyle="primary" onClick={toggleModal}>
          Show Modal
        </Button>
        <ForemanModal
          isOpen={modalOpen}
          title="I'm a modal!"
          onClose={toggleModal}
        >
          <ForemanModal.Header />
          This is the modal body. There is no footer.
        </ForemanModal>
      </Story>
    );
  })
);

storiesOf('Components/ForemanModal', module).add('With no header', () =>
  React.createElement(() => {
    const [modalOpen, toggleModal] = useModalState(false);
    return (
      <Story>
        <Button bsStyle="primary" onClick={toggleModal}>
          Show Modal
        </Button>
        <ForemanModal
          isOpen={modalOpen}
          title="I'm a modal!"
          onClose={toggleModal}
        >
          This is the modal body. There is no header.
          <ForemanModal.Footer />
        </ForemanModal>
      </Story>
    );
  })
);

storiesOf('Components/ForemanModal', module).add(
  'With props passed down via spread syntax',
  () =>
    React.createElement(() => {
      const [modalOpen, toggleModal] = useModalState(false);
      return (
        <Story>
          <Button bsStyle="primary" onClick={toggleModal}>
            Show Modal
          </Button>
          <ForemanModal
            isOpen={modalOpen}
            title="I'm a modal!"
            onClose={toggleModal}
            myProp="Hii"
          >
            <ForemanModal.Header />
            The inner {`<Modal>`} component will have any props you pass to
            {`<ForemanModal>`}. (Look in the React dev tools for
            &lsquo;myProp&rsquo;)
            <ForemanModal.Footer />
          </ForemanModal>
        </Story>
      );
    })
);
