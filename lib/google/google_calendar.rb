class Calendar
  require 'google/apis/calendar_v3'
  require 'googleauth'
  require 'googleauth/stores/file_token_store'
  require 'fileutils'

  OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
  APPLICATION_NAME = ENV['APPLICATION_NAME'].freeze
  CREDENTIALS_PATH = ENV['CREDENTIALS_PATH'].freeze
  TOKEN_PATH = 'token.yaml'.freeze
  AUTHORIZE_CODE = ENV['AUTHORIZE_CODE'].freeze
  SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR_READONLY


   # Initialize the API
  def initialize
   @service = Google::Apis::CalendarV3::CalendarService.new
   @service.client_options.application_name = APPLICATION_NAME
   @service.authorization = authorize
  end

  def authorize
    client_id   = Google::Auth::ClientId.from_file(CREDENTIALS_PATH)
    token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_PATH)
    authorizer  = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
    user_id     = 'default'
    credentials = authorizer.get_credentials(user_id)
    if credentials.nil?
      url = authorizer.get_authorization_url(base_url: OOB_URI)
      puts 'Open the following URL in the browser and enter the ' \
          "resulting code after authorization:\n" + url
      AUTHORIZE_CODE
      credentials = authorizer.get_and_store_credentials_from_code(
        user_id: user_id, code: code, base_url: OOB_URI
      )
    end
    credentials
  end

  def get_my_schedule
    # Fetch the next 10 events for the user
    calendar_id = 'primary'
    response = @service.list_events(calendar_id,
                                  max_results: 10,
                                  single_events: true,
                                  order_by: 'startTime',
                                  time_min: Time.now.iso8601)
    puts 'Upcoming events:'
    puts 'No upcoming events found' if response.items.empty?
    response.items.each do |event|
      start = event.start.date || event.start.date_time
      puts "- #{event.summary} (#{start})"
    end
  end
end