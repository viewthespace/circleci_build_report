# frozen_string_literal: true

require 'date'
require 'net/http'
require 'uri'
require 'optparse'
require 'json'
require_relative 'version'

class CircleCIBuildReport
  PAGINATION_LIMIT = 100;

  def self.start
    parse_opts
    check_opts

    earliest_seen = Date.today
    since = Date.today - 30
    offset = 0

    headers = ['build_num', 'start_time', 'stop_time', 'build_time_millis', 'outcome', 'branch', 'parallel', 'why', 'build_url']
    build_data = [headers]
    end_of_builds_reached = false

    while((since < earliest_seen) || end_of_builds_reached)
      request = CircleAPIRequest.new(
        config[:org],
        config[:project],
        config[:branch],
        config[:token],
        offset
      )
      response = request.perform
      response_body = JSON.parse(response.body)

      end_of_builds_reached = true if response_body == []

      response_body.each do |build_json|
        available_date = build_json['start_date'] || build_json['author_date'] || build_json['usage_queued_at']
        build_date = Date.parse(available_date)
        earliest_seen = build_date if build_date < earliest_seen
        build_data << build_json.fetch_values(*headers)
      end
      offset += PAGINATION_LIMIT
    end
    File.open(config[:out], 'w') { |file| file.write(build_data.map { |build| build.join(', ') }.join("\n")) }
  end

  def self.parse_opts
    OptionParser.new do |opts|
      opts.banner = 'Usage: fir [options]'
      opts.on('-v', '--version', 'Show version') do |v|
        config[:version] = v
      end
      opts.on('-g', '--org ARG', 'The name of the organization on Github/CircleCI') do |org|
        config[:org] = org
      end
      opts.on('-p', '--project ARG', 'The name of the project') do |project|
        config[:project] = project
      end
      opts.on('-b', '--branch ARG', 'The name of the branch. By default runs master') do |branch|
        config[:branch] = branch
      end
      opts.on('-o', '--out ARG', 'The name of the file to save the results to. Default is out.csv') do |out|
        config[:out] = out
      end
      opts.on('-t', '--token ARG', 'The CircleCI token') do |token|
        config[:token] = token
      end
    end.parse!
    process_immediate_opts(config)
  end

  def self.check_opts
    if !config[:org]
      raise ArgumentError.new("Please specify organization name with --org")
    end
    if !config[:project]
      raise ArgumentError.new("Please specify project name with --project")
    end
    if !config[:branch]
      raise ArgumentError.new("Please specify branch name with --branch")
    end
    if !config[:token]
      raise ArgumentError.new("Please specify CircleCI token with --token")
    end
  end

  def self.config
    @config ||= {
      branch: 'master',
      out: 'out.csv'
    }
  end

  def self.process_immediate_opts(opts)
    return unless opts[:version]
    puts(VERSION)
    exit(0)
  end

  class CircleAPIRequest
    attr_reader :org, :project, :branch, :token, :offset

    def initialize(org, project, branch, token, offset)
      @org = org
      @project = project
      @branch = branch
      @token = token
      @offset = offset
    end

    def perform
      http.use_ssl = true
      response = http.get(query_params)
    end

    def query_params
      "/api/v1.1/project/github/#{org}/#{project}/tree/#{branch}?circle-token=#{token}&limit=100&offset=#{offset}"
    end

    def uri
      @uri ||= URI.parse('https://circleci.com')
    end

    def http
      @http ||= Net::HTTP.new(uri.host, uri.port)
    end
  end
end
