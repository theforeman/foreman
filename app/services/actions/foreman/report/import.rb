module Actions
  module Foreman
    module Report
      class Import < Actions::EntryAction
        def resource_locks
          :import_reports
        end

        def plan(params, report_class, detected_proxy_id)
          plan_self :params => params, :report_class => report_class.to_s, :detected_proxy_id => detected_proxy_id
        end

        def run
          report_class = input[:report_class].constantize
          report = report_class.import(input[:params][:report], SmartProxy.find_by_id(input[:detected_proxy_id]))
          if report.errors.any?
            raise _('Failed importing of report: %s') % report.errors.full_messages
          else
            output[:report_id] = report.id
          end
        end

        def rescue_strategy
          ::Dynflow::Action::Rescue::Skip
        end

        def humanized_name
          N_("Import")
        end

        def humanized_input
          input[:report_class].constantize.humanized_name
        end
      end
    end
  end
end
