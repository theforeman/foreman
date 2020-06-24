import React from 'react';
import { Tabs, Tab, TabTitleText, Checkbox } from '@patternfly/react-core';

class SimpleTabs extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      activeTabKey: 0,
      isBox: false,
    };
    // Toggle currently active tab
    this.handleTabClick = (event, tabIndex) => {
      this.setState({
        activeTabKey: tabIndex,
      });
    };

    this.toggleBox = checked => {
      this.setState({
        isBox: checked,
      });
    };
  }

  render() {
    const { activeTabKey, isBox } = this.state;
    return (
      <div>
        <Tabs
          activeKey={activeTabKey}
          onSelect={this.handleTabClick}
          inset={{
            default: 'insetNone',
            md: 'insetSm',
            xl: 'inset2xl',
            '2xl': 'insetLg',
          }}
        >
          <Tab eventKey={0} title="Details">
            Users
          </Tab>
          <Tab eventKey={1} title="Content">
            Users
          </Tab>
          <Tab eventKey={2} title="Tasks">
            Users
          </Tab>
          <Tab eventKey={3} title="Subscriptions">
            Users
          </Tab>
        </Tabs>
      </div>
    );
  }
}

export default SimpleTabs;
