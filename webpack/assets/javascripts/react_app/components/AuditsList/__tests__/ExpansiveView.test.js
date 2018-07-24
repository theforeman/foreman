import toJson from 'enzyme-to-json';
import { shallowRenderComponentWithFixtures } from '../../../common/testHelpers';
import ExpansiveView from '../ExpansiveView';

import { AuditRecord } from './AuditsList.fixtures';

const {
  action_display_name: actionDisplayName,
  details,
  comment,
  audited_changes_with_id_to_label: auditedChangesWithIdToLabel,
  audit_title: auditTitle,
  audited_changes: auditedChanges,
} = AuditRecord;

const auditFixtures = {
  'render audit record changes': {
    actionDisplayName, details, comment, auditTitle, auditedChanges, auditedChangesWithIdToLabel,
  },
};

describe('ExpansiveView', () => {
  describe('rendering', () => {
    const components = shallowRenderComponentWithFixtures(ExpansiveView, auditFixtures);
    components.forEach(({ description, component }) => {
      it(description, () => {
        expect(component.find('.editor_source.diffMode').length).toEqual(1);
        expect(toJson(component)).toMatchSnapshot();
      });
    });
  });
});
