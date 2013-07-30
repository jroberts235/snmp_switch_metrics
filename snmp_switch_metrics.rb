#!/opt/sensu/embedded/bin/ruby
require 'snmp'
require 'sensu-plugin/metric/cli'

class SwitchMetrics < Sensu::Plugin::Metric::CLI::Graphite
  option :host,
    :short => "-H HOST",
    :long => "--host HOST",
    :description => "HOST to get metrics from",
    :default => "localhost"

  option :scheme,
    :description => "Metric naming scheme",
    :long => "--scheme SCHEME",
    :default => "stats.#{Socket.gethostname}"

  option :help,
    :long => "--help",
    :short => "-h",
    :description => "Show this message",
    :on => :tail,
    :show_options => true,
    :boolean => true,
    :exit => 0

  def walk(host,scheme)
    ifTable_columns = ["ifIndex", "ifDescr", "ifInOctets", "ifOutOctets"]
    SNMP::Manager.open(:host => host) do |manager|
      a = []
      manager.walk(ifTable_columns) do |row|
        a2 = []
        row.each do |vb|
           a2 << vb.value.to_s.tr('/', '|')
          if a2.size == 4
            a << a2
          end
        end
      end
      timestamp = Time.now.to_i
      a.each_index do |index|
        puts "#{scheme}.#{a[index][1]}.in #{a[index][2]} #{timestamp}"
        puts "#{scheme}.#{a[index][1]}.out #{a[index][3]} #{timestamp}"
      end
    end
  end
  
  def run
    host = config[:host]
    scheme = config[:scheme]
    walk(host,scheme)
    ok # exit
  end
end # Class end
