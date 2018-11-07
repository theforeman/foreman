import { testComponentSnapshotsWithFixtures } from '../../../common/testHelpers';
import ExpansiveView from '../ExpansiveView';

import { AuditRecord } from './AuditsList.fixtures';

const {
  action_display_name: actionDisplayName,
  details,
  comment,
  audited_changes_with_id_to_label: auditedChangesWithIdToLabel,
  audited_changes: auditedChanges,
} = AuditRecord;

const auditFixtures = {
  'render audit record changes': {
    actionDisplayName,
    details,
    comment,
    auditedChanges,
    auditedChangesWithIdToLabel,
  },
};

describe('ExpansiveView', () => {
  describe('rendering', () =>
    testComponentSnapshotsWithFixtures(ExpansiveView, auditFixtures));
});
