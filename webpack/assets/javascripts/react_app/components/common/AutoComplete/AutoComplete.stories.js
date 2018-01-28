/* eslint-disable no-alert */
import React, { Component } from 'react';
import { storiesOf } from '@storybook/react';
import { Row, Col } from 'patternfly-react';

import AutoComplete from './index';
import { countItems } from './AutoComplete.fixtures';

export class AutoCompleteExample extends Component {
  constructor(props) {
    super(props);
    this.state = { items: countItems };
    this.onInputUpdate = this.onInputUpdate.bind(this);
  }

  componentDidMount() {
    this.onInputUpdate();
  }

  onInputUpdate(searchTerm = '') {
    this.setState({
      items: countItems.filter(i => !searchTerm || i.includes(searchTerm)),
    });
  }

  render() {
    return (
      <AutoComplete
        items={this.state.items}
        labelText="Type a number one through ten"
        onInputUpdate={this.onInputUpdate}
        onSearch={selection => alert(`You selected ${selection}!`)}
      />
    );
  }
}

storiesOf('AutoComplete', module)
  .addDecorator(getStory => (
    <div style={{ padding: 20 }}>
      <Row>
        <Col sm={3} />
        <Col sm={6}>{getStory()}</Col>
      </Row>
      <Row>
        <Col sm={3} />
        <Col sm={6}>
          <p>The dropdown should overlay this text.</p>
        </Col>
      </Row>
    </div>
  ))
  .add('AutoComplete', () => <AutoCompleteExample />);
