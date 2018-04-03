import React from 'react';
import { Button, Icon } from 'patternfly-react';

class BreadcrumbSwitcherToggler extends React.Component {
  render() {
    return (
      <Button {...this.props}>
        <Icon type="fa" name="exchange" />
      </Button>
    );
  }
}

BreadcrumbSwitcherToggler.propTypes = { ...Button.propTypes };

export default BreadcrumbSwitcherToggler;
