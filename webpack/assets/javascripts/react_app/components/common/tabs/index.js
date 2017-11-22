import React from 'react';
import {
  TabContainer,
  Nav,
  NavItem,
  TabPane,
  TabContent,
} from 'patternfly-react';

const TabsWrapper = (props) => {
  const { tabs, children } = props;
  return (
    <TabContainer id="basic-tabs-pf" defaultActiveKey={0}>
      <div>
        <Nav bsClass="nav nav-tabs nav-tabs-pf" justified>
          {tabs.map((tab, index) => (
            <NavItem key={index} eventKey={index}>
              {tab}
            </NavItem>
          ))}
        </Nav>

        <TabContent animation>
          {React.Children.map(children, (content, index) => (
            <TabPane eventKey={index}>{content}</TabPane>
          ))}
        </TabContent>
      </div>
    </TabContainer>
  );
};

export default TabsWrapper;
