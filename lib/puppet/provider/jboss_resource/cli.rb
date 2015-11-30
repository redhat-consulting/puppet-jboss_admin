require 'puppet/parser/functions'
require 'puppet/util/cli_execution'
require 'json'

Puppet::Type.type(:jboss_resource).provide(:cli) do
  desc "Manages JBoss container resources via the CLI"
  include Puppet::Util::CliExecution
  extend Puppet::Util::CliExecution

  def self.prefetch(resources)
    cached_results = {}
    parser = CliParser.new

    resources.each do |name, resource|
      # don't try to prefetch if noop
      unless resource[:noop]

        # dump the root resrouce and cache it
        if cached_results[resource[:server]].nil?
          cached_results[resource[:server]] = execute_cli get_server(resource), format_command('/', 'read-resource', {:recursive => true}), false
        end

        # get the current value of for the given address
        path     = parser.parse_path(resource[:address])
        is_value = PathGenerator.root_dump_position(path, cached_results[resource[:server]]['result'])

        # if address exists in cache create attributes as present with current value
        # else create attributes as absent
        attributes = {:name => name, :address => resource[:address]}
        if is_value
          attributes[:ensure]  = :present
          attributes[:options] = is_value
        else
          attributes[:ensure] = :absent
        end

        resource.provider = new attributes
      end
    end
  end

  def initialize(value={})
    super(value)
    @new_values = {}
  end

  def create
    @new_values[:ensure] = :present
  end

  def destroy
    @new_values[:ensure] = :absent
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def options
    @property_hash[:options]
  end

  def options=(value)
    @new_values[:options] = value
  end

  def flush
    tries      = resource[:tries]
    try_sleep  = resource[:try_sleep]
    last_error = nil
    result     = nil

    # attempt to apply the resource changes the given number of tries
    tries.times do |try|
      begin
        # Only add debug messages for tries > 1 to reduce log spam.
        debug("Resource try #{try+1}/#{tries}") if tries > 1
 
        if @new_values[:ensure] == :absent
          result = execute_cli get_server(resource), format_command(resource[:address], 'remove')
          raise "Error removing resource" unless result['outcome'] == 'success'
          return
        elsif @new_values[:ensure] == :present
          result = execute_cli get_server(resource), format_command(resource[:address], 'add', resource[:options])
          raise "Error creating resource" unless result['outcome'] == 'success'
          return
        elsif @new_values[:options]
          undefines = @new_values[:options].select{ |key, value| value == 'undefined' && @property_hash[key]}.collect{ |key, value| key}
          changes = @new_values[:options].to_a - @property_hash[:options].to_a
          commands = changes.collect { |attribute, value| 
            format_command resource[:address], 'write-attribute', {'name' => attribute, 'value' => value}
          } + undefines.collect { |attribute|
            format_command resource[:address], 'undefine-attribute', {'name' => attribute}
          }

          result = execute_cli get_server(resource), commands, false, true
          raise "Failed setting attribute, #{result['failure-description']}" unless result['outcome'] == 'success'
          return
        end

        # sleep before next attempt
        if try_sleep > 0 and tries > 1
          debug("Sleeping for #{try_sleep} seconds between tries")
          sleep try_sleep
        end
      rescue => e
        last_error = e
      end
    end

    # if never succeeded then re-raise the last error
    if last_error
      raise last_error
    end
  end

end
