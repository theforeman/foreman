$(function(){
  $(".statistics_pie").each(function(index, element){
    var el = $(element);
    var name = el.attr('chart-name');
    var title = el.attr('chart-title');
    var data = $.parseJSON(el.attr('chart-data'));

    stat_pie(name, title, data);
  });

  $(".statistics_bar").each(function(index, element){
    var el = $(element);
    var name = el.attr('chart-name');
    var title = el.attr('chart-title');
    var yTitle = el.attr('chart-yTitle');
    var labels = $.parseJSON(el.attr('chart-labels'));
    var data = $.parseJSON(el.attr('chart-data'));

    stat_bar(name, title, subtitle, labels, data);
  });
});

function stat_pie(name, title, data) {
    new Highcharts.Chart({
      chart: {
        renderTo: name,
        borderColor: '#909090',
        borderWidth: 1,
        backgroundColor: {
         linearGradient: [0, 0, 0, 200],
         stops: [
            [0, '#ffffff'],
            [1, '#EDEDED']
         ]}
      },
      credits: {
        enabled: false
      },
      title: {
         text: title,
         style: {color: '#000000'}
      },
      tooltip: {
         formatter: function() {
            return '<b>'+ this.point.name +'</b>: '+ this.y;
         }
      },
      plotOptions: {
         pie: {
            allowPointSelect: true,
            cursor: 'pointer',
            dataLabels: {
               enabled: true,
               formatter: function() {
                  return  this.point.name + ': '+ Math.round(this.y*100)/100;
               }
            }
         }
      },
       series: [{
         type: 'pie',
         name: '',
         data: data
      }]
    });
  }

 function stat_bar(name, title, yTitle, labels, data) {
   new Highcharts.Chart({
      chart: {
        renderTo: name,
        defaultSeriesType: 'column',
        margin: [ 50, 50, 100, 80],
        borderColor: '#909090',
        borderWidth: 1,
        backgroundColor: {
         linearGradient: [0, 0, 0, 200],
         stops: [
            [0, '#ffffff'],
            [1, '#EDEDED']
         ]}
      },
      credits: {
        enabled: false
      },
      title: {
         text: title,
         style: {color: '#000000'}
      },
      xAxis: {
         categories: labels ,
         labels: {
            rotation: -45,
            align: 'right',
            style: {
                font: 'normal 13px Verdana, sans-serif'
            }
         }
      },
      yAxis: {
         min: 0,
         title: {
            text: yTitle,
            style: {color: '#000000'}
         }
      },
      legend: {
         enabled: false
      },
      tooltip: {
         formatter: function() {
            return '<b>'+ this.x +'</b><br/>'+
                yTitle+': '+ Highcharts.numberFormat(this.y, 1);
         }
      },
           series: [{
         name: 'Clients_Count',
         data:  data ,
         dataLabels: {
            enabled: false,
            rotation: -90,
            align: 'right',
            x: -3,
            y: 10,
            formatter: function() {
               return this.y;
            },
            style: {
               font: 'normal 13px Verdana, sans-serif'
            }
         }
      }]
   });
 }