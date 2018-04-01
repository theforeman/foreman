import React from 'react';
import {
  Popover,
  Button,
  Icon,
  ListGroup,
  ListGroupItem,
  OverlayTrigger,
} from 'patternfly-react';
import { ButtonToolbar } from 'react-bootstrap';
import EllipsisWithTooltip from 'react-ellipsis-with-tooltip';
import PropTypes from 'prop-types';
import './BreadcrumbSwitcher.scss';

const BreadcrumbSwitcher = ({ resources }) => {
  const popover = (
    <Popover id="popover-contained">
      <ListGroup className="scrollable-list">
        {resources.map((item) => {
          const { onClick, url, caption } = item;
          return (
            <ListGroupItem
              className="no-border"
              key={`id-${caption}`}
              href={url}
              onClick={onClick}
            >
              <EllipsisWithTooltip>{caption}</EllipsisWithTooltip>
            </ListGroupItem>
          );
        })}
      </ListGroup>
    </Popover>
  );
  return (
    <ButtonToolbar>
      <OverlayTrigger
        rootClose
        trigger="click"
        placement="bottom"
        overlay={popover}
      >
        <Button>
          <Icon type="fa" name="exchange" />
        </Button>
      </OverlayTrigger>
    </ButtonToolbar>
  );
};

BreadcrumbSwitcher.propTypes = {
  href: PropTypes.string,
  onClick: PropTypes.func,
  caption: PropTypes.string,
};

export default BreadcrumbSwitcher;
