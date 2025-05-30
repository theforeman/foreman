export const notificationsFixtures = [
        {
            "id": 43,
            "seen": false,
            "level": "error",
            "text": "A job 'Run scan for all OpenSCAP policies on host' has failed",
            "created_at": "2025-05-30T08:47:18.376Z",
            "group": "Jobs",
            "actions": {
                "links": [
                    {
                        "href": "/job_invocations/13",
                        "title": "Job Details"
                    }
                ]
            }
        },
        {
            "id": 42,
            "seen": true,
            "level": "info",
            "text": "Report \"Job - Invocation Report\" is ready to download",
            "created_at": "2025-05-30T08:15:19.685Z",
            "group": "Reports",
            "actions": {
                "links": [
                    {
                        "title": "Download Report",
                        "href": "/templates/report_templates/167-Job%20-%20Invocation%20Report/report_data?job_id=39ac5f55-a6f1-4ca3-92f9-2669d5e3d07b"
                    },
                    {
                        "title": "Regenerate Report",
                        "href": "/templates/report_templates/167-Job%20-%20Invocation%20Report/generate?report_template_report%5Binput_values%5D%5B34%5D%5Bvalue%5D=66&report_template_report%5Binput_values%5D%5B35%5D%5Bvalue%5D="
                    }
                ]
            }
        }
    ];
