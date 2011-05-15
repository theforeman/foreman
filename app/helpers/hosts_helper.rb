module HostsHelper
  include CommonParametersHelper
  include OperatingsystemsHelper
  include HostsAndHostgroupsHelper

  def last_report_column(record)
    return nil if record.last_report.nil?
    time = time_ago_in_words(record.last_report.getlocal)
    image_tag("#{not (record.error_count > 0 or record.no_report)}.png", :size => "18x18") +
      link_to_if_authorized(time,  hash_for_host_report_path(:host_id => record.to_param, :id => "last", :enable_link => @last_reports[record.id]))
  end

# method that reformats the hostname column by adding the status icons
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
        ['Destroy Hosts', multiple_destroy_hosts_path],
        ['Disable Notifications', multiple_disable_hosts_path],
        ['Enable Notifications', multiple_enable_hosts_path],
    ]
    actions << ['Build Hosts', multiple_build_hosts_path] if SETTINGS[:unattended]

    select_tag "Multiple Actions", options_for_select(actions.sort), :id => "Submit_multiple", :onchange => 'submit_multiple(this.value)'
  end


  def selected? host
    return false if host.nil? or not host.is_a?(Host) or session[:selected].nil?
    session[:selected].include?(host.id.to_s)
  end

  def select_hypervisor
    options_for_select Hypervisor.all.map{|h| [h.name, h.id]}, @host.try(:hypervisor_id).try(:to_i)
  end


  def select_memory memory = nil
    options_for_select Hypervisor::MEMORY_SIZE.map {|mem| [number_to_human_size(mem*1024), mem]}, memory.to_i
  end

  def accessible_domains
    (User.current.domains.any? and !User.current.admin?) ? User.current.domains : Domain.all
  end

  def accessible_hostgroups
    (User.current.hostgroups.any? and !User.current.admin?) ? User.current.hostgroups : Hostgroup.all
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
   chart = new Highcharts.Chart({
      chart: {
         renderTo: '#{name}',
         defaultSeriesType: 'line',
         zoomType: 'x',
         margin: [ 50, 50, 90, 50],
         borderWidth: 2,
         backgroundColor: {
         linearGradient: [0, 0, 0, 300],
         stops: [
            [0, '#ffffff'],
            [1, '#EDF6FC']
         ]}
      },
      title: {
         text: '#{title}',
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
       '#AA4643',
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
         borderWidth: 2,
         backgroundColor: {
         linearGradient: [0, 0, 0, 300],
         stops: [
            [0, '#ffffff'],
            [1, '#EDF6FC']
         ]}
      },
      title: {
         text: '#{title}',
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
end
