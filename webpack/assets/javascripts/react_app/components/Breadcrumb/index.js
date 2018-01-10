import React from 'react';
import { Breadcrumb } from 'patternfly-react';
import 'patternfly-react/dist/sass/_breadcrumb.scss';

const ForemanBreadcrumb = ({ data }) => {
  if (data.menu.length === 1) {
    return (
      <div className="form-group">
        <h1>{data.menu[0].caption}</h1>
      </div>
    );
  }
  return (
    <div>
      <Breadcrumb title>
        {data.menu.map((item, index) => (
          <Breadcrumb.Item
            key={index}
            active={index === data.menu.length - 1}
            href={item.url}
            dangerouslySetInnerHTML={{ __html: item.caption }}
          />
        ))}
      </Breadcrumb>
      <hr className="breadcrumb-line" />
    </div>
  );
};

export default ForemanBreadcrumb;
