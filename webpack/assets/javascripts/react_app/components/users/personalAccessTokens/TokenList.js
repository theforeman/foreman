import React from 'react';
import Token from './Token';
import Panel from '../../common/Panel/Panel';
import PanelHeading from '../../common/Panel/PanelHeading';
import PanelTitle from '../../common/Panel/PanelTitle';
import PanelBody from '../../common/Panel/PanelBody';

export default ({ tokens, title, emptyText, revokeToken, revocable = false }) => (
  <Panel>
    <PanelHeading>
      <PanelTitle text={`${title} (${tokens ? tokens.length : ''})`} />
    </PanelHeading>
    <PanelBody>
      {(tokens &&
        tokens.length > 0 && (
          <table className="table table-bordered table-striped table-fixed">
            <thead>
              <tr>
                <th>{__('Name')}</th>
                <th>{__('Created')}</th>
                <th>{revocable ? __('Expires') : __('Expired')}</th>
                <th>{__('Last Used')}</th>
                <th>{__('Actions')}</th>
              </tr>
            </thead>
            <tbody>
              {tokens &&
                tokens.map(token =>
                  <Token key={token.id} {...token} revocable={revocable}
                    revokeToken={() => revokeToken(token.user_id, token.id) } />
                )}
            </tbody>
          </table>
        )) ||
        emptyText}
    </PanelBody>
  </Panel>
);
