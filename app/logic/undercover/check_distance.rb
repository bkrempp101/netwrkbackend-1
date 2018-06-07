class Undercover::CheckDistance
  include Service

  def initialize(post_code, current_lng, current_lat, user)
    @post_code = post_code
    @current_lng = current_lng
    @current_lat = current_lat
    @user = user
  end

  def perform
    messages_in_radius
  end

  private

  attr_reader :post_code, :user, :current_lng, :current_lat

  def messages_in_radius
    messages_in_radius = []
    # network = Network.find_by(post_code: post_code)
    messages = Message.undercover_is(true).with_users
    messages.each do |message|
      next unless (message.lat.to_s[0..4] == current_lat.to_s[0..4]) &&
                  (message.lng.to_s[0..4] == current_lng.to_s[0..4])
      distance = Geocoder::Calculations.distance_between(
        [current_lng, current_lat], [message.lng, message.lat]
      )
      message.current_user = user
      if in_radius?(miles_to_yards(distance)) && !message.deleted_by_user?
        messages_in_radius << message
      end
    end
    messages_in_radius
  end

  def miles_to_yards(miles)
    miles * 1760
  end

  def in_radius?(yards)
    yards <= 100
  end
end
