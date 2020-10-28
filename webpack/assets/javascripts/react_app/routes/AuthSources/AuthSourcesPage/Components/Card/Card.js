import React from 'react';
import {
  // Brand,
  Card,
  CardHead,
  // CardHeadMain,
  CardActions,
  CardHeader,
  CardBody,
  CardFooter,
  Dropdown,
  // DropdownToggle,
  DropdownItem,
  DropdownSeparator,
  // DropdownPosition,
  // DropdownDirection,
  KebabToggle,
} from '@patternfly/react-core';

class AuthSourceCard extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      isOpen: false,
      check1: false,
    };
    this.onToggle = isOpen => {
      this.setState({
        isOpen,
      });
    };
    this.onSelect = event => {
      this.setState({
        isOpen: !this.state.isOpen,
      });
    };
  }

  render() {
    const { isOpen } = this.state;
    const dropdownItems = [
      <DropdownItem key="link">Link</DropdownItem>,
      <DropdownItem key="action" component="button">
        Action
      </DropdownItem>,
      <DropdownItem key="disabled link" isDisabled>
        Disabled Link
      </DropdownItem>,
      <DropdownItem key="disabled action" isDisabled component="button">
        Disabled Action
      </DropdownItem>,
      <DropdownSeparator key="separator" />,
      <DropdownItem key="separated link">Separated Link</DropdownItem>,
      <DropdownItem key="separated action" component="button">
        Separated Action
      </DropdownItem>,
    ];
    return (
      <Card>
        <CardHead>
          <CardActions>
            <Dropdown
              onSelect={this.onSelect}
              toggle={<KebabToggle onToggle={this.onToggle} />}
              isOpen={isOpen}
              isPlain
              dropdownItems={dropdownItems}
              position={'right'}
            />
          </CardActions>
        </CardHead>
        <CardHeader>Header</CardHeader>
        <CardBody>Body</CardBody>
        <CardFooter>Footer</CardFooter>
      </Card>
    );
  }
}

export default AuthSourceCard;
