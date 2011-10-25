module HostsHelper
  include OperatingsystemsHelper
  include HostsAndHostgroupsHelper

  def last_report_column(record)
    return nil if record.last_report.nil?
    time = time_ago_in_words(record.last_report.getlocal)
    link_to_if_authorized(report_icon(record) + time,
                          hash_for_host_report_path(:host_id => record.to_param, :id => "last"),
                          last_report_column_html(record))
  end

  def last_report_column_html record
    opts = { :rel => "twipsy" }
    if @last_reports[record.id]
      opts.merge!( "data-original-title" => "View last reprot details")
    else
      opts.merge!(
        "data-original-title" => "Report Already Deleted",
        :disabled => true, :class => "disabled", :onclick => 'return false'
      )
      opts
    end
  end

# method that reformat the hostname column by adding the status icons
  def name_column(record)
    if record.build and not record.installed_at.nil?
      image ="attention_required.png"
      title = "Pending Installation"
    elsif (os = @fact_kernels.select{|h| h.host_id == record.id}.first.value rescue nil).nil?
      image = "warning.png"
      title = "No Inventory Data"
    else
      image = "#{os}.jpg"
      title = os
    end
    image_tag("hosts/#{image}", :size => "18x18", :title => title) +
      link_to(record.shortname, host_path(record))
  end

  def days_ago time
    ((Time.now - time) / 1.day).round.to_i
  end

  def authorized?
    authorized_for(:hosts, :edit) or authorized_for(:hosts, :destroy)
  end

  def searching?
    params[:search].empty?
  end

  def multiple_actions_select
    actions = [
        ['Change Group', select_multiple_hostgroup_hosts_path],
        ['Change Environment', select_multiple_environment_hosts_path],
        ['Edit Parameters', multiple_parameters_hosts_path],
        ['Delete Hosts', multiple_destroy_hosts_path],
        ['Disable Notifications', multiple_disable_hosts_path],
        ['Enable Notifications', multiple_enable_hosts_path],
    ]
    actions << ['Build Hosts', multiple_build_hosts_path] if SETTINGS[:unattended]

    select_tag "Multiple Actions", options_for_select(actions.sort), :id => "Submit_multiple", :onchange => 'submit_multiple(this.value)',
      :class => "medium", :title => "Perform Actions on multiple hosts"
  end

  def date ts=nil
    return "#{time_ago_in_words ts} ago" if ts
    "N/A"
  end

  def template_path opts = {}
    if t = @host.configTemplate(opts)
      link_to t, edit_config_template_path(t)
    else
      "N/A"
    end
  end

  def selected? host
    return false if host.nil? or not host.is_a?(Host) or session[:selected].nil?
    session[:selected].include?(host.id.to_s)
  end

  def update_details_from_hostgroup
    return nil unless @host.new_record?
    remote_function(:url => { :action => "process_hostgroup" },
                    :method => :post, :loading => "$('#indicator1').show()",
                    :complete => "$('#indicator1').hide()",
                    :with => "'hostgroup_id=' + value")
  end

  def render_report_status_chart name, title, subtitle, data
  function = <<-EOF
  $(function() {
    Highcharts.setOptions({
      global: {
        useUTC: false
      }
    });
   chart = new Highcharts.Chart({
      chart: {
         renderTo: '#{name}',
         defaultSeriesType: 'line',
         zoomType: 'x',
         margin: [ 50, 50, 90, 50],
         borderColor: '#909090',
         borderWidth: 1,
         backgroundColor: {
         linearGradient: [0, 0, 0, 300],
         stops: [
            [0, '#ffffff'],
            [1, '#EDEDED']
         ]}
      },
      title: {
         text: '#{title}',
         style: {color: '#000000'},
         x: -20 //center
      },
      subtitle: {
         text: '#{subtitle}',
         x: -20
      },
      credits: {
      enabled: false,
      },
      xAxis: {
         type: 'datetime',
         labels: {
            rotation: -45,
            align: 'right',
            style: {
                font: 'normal 13px Verdana, sans-serif'
            }
         }
      },
      yAxis: {
         title: {
            text: 'Number of Events'
         },
         min: 0
      },
      tooltip: {
         formatter: function() {
                   return '<b>'+ this.series.name + ': ' + this.y + '</b><br/>'+
              Highcharts.dateFormat('%e. %b %H:%M', this.x)  ;
         }
      },
      legend: {
         layout: 'horizontal',
         align: 'bottom',
         verticalAlign: 'bottom',
         x: 10,
         y: -10,
         borderWidth: 0
      },
      colors: [
       '#AA4643',
       '#AA4643',
       '#80699B',
       '#89A54E',
       '#4572A7',
       '#80699B',
       '#3D96AE',
       '#DB843D',
       '#92A8CD',
       '#A47D7C',
       '#B5CA92'
      ],
      series: [{
         name: 'Failed',
         data: [ #{data[:failed].join(' ,')} ]
      }, {
         name: 'Failed restarts',
         data: [#{data[:failed_restarts].join(' ,')}]
      }, {
         name: 'Skipped',
         data: [#{data[:skipped].join(' ,')}]
      }, {
         name: 'Applied',
         data: [#{data[:applied].join(' ,')}]
      }, {
         name: 'Restarted',
         data: [#{data[:restarted].join(' ,')}]
      }]
   });


  });
EOF
    javascript_tag(function)
  end
 def render_runtime_chart name, title, subtitle, data
  function = <<-EOF
  $(function() {
   chart = new Highcharts.Chart({
      chart: {
         renderTo: '#{name}',
         defaultSeriesType: 'area',
         zoomType: 'x',
         margin: [ 50, 50, 90, 50],
         borderColor: '#909090',
         borderWidth: 1,
         backgroundColor: {
         linearGradient: [0, 0, 0, 300],
         stops: [
            [0, '#ffffff'],
            [1, '#EDEDED']
         ]}
      },
      title: {
         text: '#{title}',
         style: {color: '#000000'},
         x: -20 //center
      },
      subtitle: {
         text: '#{subtitle}',
         x: -20
      },
      credits: {
      enabled: false,
      },
      xAxis: {
         type: 'datetime',
         labels: {
            rotation: -45,
            align: 'right',
            style: {
                font: 'normal 13px Verdana, sans-serif'
            }
         }
      },
      yAxis: {
         title: {
            text: 'Time in Seconds'
         },
         min: 0
      },
      tooltip: {
         formatter: function() {
                   return '<b>'+ this.series.name + ': ' + this.y + '</b><br/>'+
              Highcharts.dateFormat('%e. %b %H:%M', this.x)  ;
         }
      },
      legend: {
         layout: 'horizontal',
         align: 'bottom',
         verticalAlign: 'bottom',
         x: 10,
         y: -10,
         borderWidth: 0
      },
      plotOptions: {
         area: {
            lineWidth: 1,
            stacking: 'normal',
            marker: {
               enabled: false,
               symbol: 'circle',
               radius: 2,
               states: {
                  hover: {
                     enabled: true
                  }
               }
            }
         }
      },
      series: [{
         name: 'Runtime',
         data: [ #{data[:runtime].join(' ,')} ]
      }, {
         name: 'Config Retrieval',
         data: [#{data[:config].join(' ,')}]
      }]
   });
  });
EOF
    javascript_tag(function)
 end

  def reports_show
    return unless @host.reports.size > 0
    form_tag @host, :id => 'days_filter', :method => :get do
      content_tag(:p, {}) { "Reports from the last " +
        select(nil, 'range', 1..days_ago(@host.reports.first.reported_at),
               {:selected => @range}, {:class=>"span2", :onchange =>"$('#days_filter').submit();$(this).disabled();"}) +
               " days - #{@host.reports.recent(@range.days.ago).count} reports found"
      }
    end
  end
end
