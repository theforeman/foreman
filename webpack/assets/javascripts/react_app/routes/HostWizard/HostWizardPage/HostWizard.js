import React from 'react';
import { Wizard, Button, Icon } from 'patternfly-react';
import PageLayout from '../../common/PageLayout/PageLayout';
import { translate as __ } from '../../../common/I18n';

class LoadingWizardExample extends React.Component {
  constructor(props) {
    super(props);
    this.state = { showModal: false };
  }
  close = () => {
    this.setState({ showModal: false });
  };
  open = () => {
    this.setState({ showModal: true });
  };
  render() {
    const { showModal } = this.state;

    return (
      <PageLayout header={__('Host Wizard')} searchable={false}>
        <Button bsStyle="primary" bsSize="large" onClick={this.open}>
          Launch loading wizard
        </Button>

        <Wizard show={showModal} onHide={this.close}>
          <Wizard.Header onClose={this.close} title="Wizard Title" />
          <Wizard.Body>
            <Wizard.Row>
              <Wizard.Main>
                <div className="blank-slate-pf">
                  <div
                    className="spinner spinner-lg blank-slate-pf-icon"
                    style={{ float: 'none' }}
                  />
                  <h3 className="blank-slate-pf-main-action">
                    This will be one of our coolest pages.
                  </h3>
                </div>
              </Wizard.Main>
            </Wizard.Row>
          </Wizard.Body>
          <Wizard.Footer>
            <Button
              bsStyle="default"
              className="btn-cancel"
              onClick={this.close}
            >
              Cancel
            </Button>
            <Button bsStyle="default" disabled>
              <Icon type="fa" name="angle-left" />
              Back
            </Button>
            <Button bsStyle="primary" disabled>
              Next
              <Icon type="fa" name="angle-right" />
            </Button>
          </Wizard.Footer>
        </Wizard>
      </PageLayout>
    );
  }
}

export default LoadingWizardExample;
