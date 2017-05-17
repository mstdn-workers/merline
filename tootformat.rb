# coding: utf-8

module Formatter
  TOOT_FORMAT = lambda { |username, display_name, content, time_local|
    "[#{time_local}]\t#{display_name}\t@#{username}\t#{content}"
  }

  class TootFormatter
    def to_s
      Formatter::TOOT_FORMAT.call(@username, @display_name, @content, @time_local)
    end

    def initialize(status)
      account = status.account
      content = status.content
      @username = account.acct
      @display_name = "#{DisplayNameFormatter.new status}"
      @time_local = Time.iso8601(status.created_at).localtime

      # @content = preprocess_content content
      @content = content
    end

    private
    def remove_tag(str)
      str.gsub(/<([^>]+)>/, "")
    end

    def process_image!(content)
      content.gsub!(/<a.+?href="([^"]*)".+?<\/a>/) do |x|
        "[image: " + $1 + "]"
      end
    end

    def process_hashtag!(content)
      # 何かの役に立つかもしれないから、$1でurlを取れるようにはしてある
      content.gsub!(/<a href="([^"]*)[^>]*>#<span>(.+?)<\/span><\/a>/) do |text|
        "#" + $2
      end
    end

    def process_link!(content)

    end

    def br(content)
      content.gsub(/<br \/>/, "\n")
    end

    def preprocess_content(content)
      content = content.gsub(/<p>(.*)<\/p>/m) { $1 }
      content = content.gsub(/<p><\/p>/, "<br /><br />") # あんま美しくないので段落については考える
      # content = remove_tag content  # 対処しなきゃいけないタグを見やすくするため今はコメントアウト
      # process_hashtag! content
      # process_link! content
      #   process_image! content
      content = br content
      CGI.unescapeHTML content
    end
  end

  class DisplayNameFormatter
    require 'gemoji'

    def emojify(str)
      str.gsub(/:([\w+-]+?):/) { |matched|
        if emoji = Emoji.find_by_alias($1) then
          emoji.raw
        else
          matched
        end
      }
    end

    def to_s
      emojify @display_name
    end

    def initialize(status)
      account = status.account
      @username = account.acct
      @display_name = account.display_name
      @display_name = @username if @display_name.empty?
    end
  end

  def self.format_status(status)
    require 'cgi'
    return if not status.respond_to?(:account)
    return if not status.respond_to?(:content)
    t = TootFormatter.new status
    t.to_s
  end
end
