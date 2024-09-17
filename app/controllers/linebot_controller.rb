class LinebotController < ApplicationController
  before_action :require_login
  skip_before_action :verify_authenticity_token, only: [:callback]
  skip_before_action :require_login, only: [:callback]

  require 'line/bot'

  def callback
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      head :bad_request
      return
    end

    events = client.parse_events_from(body)

    events.each do |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          message = {
          type: 'text',
            text: event.message['text']
          }
          client.reply_message(event['replyToken'], message)
      end
    end
  end

  head :ok
end

  private

  def client
    @client ||= Line::Bot::Client.new do |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]

    end
  end
end

#返答に文字列を追加するパターン
# class LinebotController < ApplicationController
#   before_action :require_login
#   skip_before_action :verify_authenticity_token, only: [:callback]
#   skip_before_action :require_login, only: [:callback]

#   def callback
#     body = request.body.read
#     signature = request.env['HTTP_X_LINE_SIGNATURE']
#     unless client.validate_signature(body, signature)
#       error 400 do 'Bad Request' end
#     end
#     events = client.parse_events_from(body)

#     events.each do |event|
#       case event
#       when Line::Bot::Event::Message

#         if event.type == Line::Bot::Event::MessageType::Text
#          response_message = "今回の回答: #{event.message['text']}"
#           message = {
#           type: 'text',
#             text: response_message
#           }
#       end
#     end
#     client.reply_message(event['replyToken'], message)
#   end
#   head :ok
# end

#   private

#   def client
#     @client ||= Line::Bot::Client.new {|config|
#       config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
#       config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
#     }
#   end
# end
