require 'net/http'
require 'json'
require 'uri'
require 'readline'

class ClaudeService
  class APIError < StandardError; end

  API_URL = URI('https://api.anthropic.com/v1/messages')

  def initialize(api_key)
    @api_key = api_key
    @http_client = setup_http_client
  end

  def send_message(messages)
    request = build_request(messages)
    response = @http_client.request(request)
    handle_response(response)
  end

  private

  def setup_http_client
    http = Net::HTTP.new(API_URL.host, API_URL.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    http
  end

  def build_request(messages)
    request = Net::HTTP::Post.new(API_URL)
    request['anthropic-version'] = '2023-06-01'
    request['x-api-key'] = @api_key
    request['content-type'] = 'application/json'

    request.body = {
      model: 'claude-3-opus-20240229',
      max_tokens: 4096,
      messages: messages
    }.to_json

    request
  end

  def handle_response(response)
    case response
    when Net::HTTPSuccess
      data = JSON.parse(response.body, symbolize_names: true)
      message = data.dig(:content, 0, :text)
      raise APIError, 'Invalid API response format' unless message
      message
    else
      raise APIError, "API request failed (#{response.code}): #{response.body}"
    end
  rescue JSON::ParserError
    raise APIError, 'Invalid JSON response from API'
  end
end

class CodeFormatter
  def initialize(left_padding, terminal_width)
    @left_padding = left_padding
    @terminal_width = terminal_width
  end

  def format_code(line, language, current_indent)
    stripped_line = line.strip

    case language&.downcase
    when 'ruby'
      current_indent = calculate_ruby_style_indent(stripped_line, current_indent)
    else
      current_indent = calculate_c_style_indent(stripped_line, current_indent)
    end

    formatted_line = (" " * @left_padding) + (" " * (current_indent * 2)) + stripped_line
    [formatted_line, current_indent]
  end

  private

  def calculate_ruby_style_indent(line, current_indent)
    next_indent = current_indent

    # Dedent for keywords that close blocks
    if line =~ /^(end|else|elsif|when|rescue|ensure)$/
      next_indent = [current_indent - 1, 0].max
    end

    # Indent for keywords that open blocks
    if line =~ /\b(class|module|def|if|unless|case|while|until|for|begin|do)\b/ || line =~ /[\{\(\[]$/
      next_indent += 1
    end

    # Handle inline blocks (e.g., `do ... end`)
    if line =~ /\bdo\b.*\bend\b/ || line =~ /\{.*\}/
      # Do not change the indentation level for inline blocks
    end

    next_indent
  end

  def calculate_c_style_indent(line, current_indent)
    next_indent = current_indent

    # Dedent for closing braces
    if line =~ /^[}\])]$/
      next_indent = [current_indent - 1, 0].max
    end

    # Indent for opening braces
    if line =~ /{[^}]*$/ || line =~ /\[[^\]]*$/ || line =~ /\([^)]*$/
      next_indent += 1
    end

    next_indent
  end
end

class AIChat
  def initialize
    @conversation_history = []
    @command_history = []
    @typing_interrupted = false
    @terminal_width = `tput cols`.to_i rescue 80
    @left_padding = (@terminal_width * 0.25).to_i
    @right_margin = (@terminal_width * 0.1).to_i
    @code_formatter = CodeFormatter.new(@left_padding, @terminal_width)
    setup_claude
  end

  def start
    system('clear') || system('cls')
    padding = " " * @left_padding
    puts "\n#{padding}AI Chat"
    puts "#{padding}Commands: 'exit' to quit, 'clear' to reset conversation"
    puts "#{padding}Press Ctrl+C to stop the current response"

    while input = Readline.readline("\n#{padding}You: ", true)
      break if input.downcase == 'exit'

      case input.downcase
      when 'clear'
        @conversation_history.clear
        puts "#{padding}Conversation history cleared."
      else
        handle_user_input(input) unless input.strip.empty?
      end
    end

    puts "\n#{padding}Goodbye!"
  end

  private

  def setup_claude
    padding = " " * @left_padding
    api_key = Readline.readline("\n#{padding}Enter your Anthropic API key: ", false)
    @service = ClaudeService.new(api_key)
    puts "\n#{padding}Claude configured successfully!"
  end

  def handle_user_input(input)
    padding = " " * @left_padding
    print "#{padding}Thinking..."

    @conversation_history << { role: 'user', content: input }
    response = @service.send_message(@conversation_history)
    @conversation_history << { role: 'assistant', content: response }

    print "\r#{' ' * @terminal_width}\r"
    print "#{padding}AI: "
    type_text(response)
  rescue StandardError => e
    puts "\n#{padding}Error: #{e.message}"
  end

  def type_text(text, speed = 0.03)
    padding = " " * @left_padding
    @typing_interrupted = false

    begin
      current_indent_level = 0
      in_code_block = false
      code_buffer = []
      lines = text.split("\n")

      lines.each do |line|
        if line.strip =~ /^```(\w+)?$/
          language = $1
          if in_code_block
            code_buffer.each do |code_line|
              raise Interrupt if @typing_interrupted
              formatted_line, current_indent_level = @code_formatter.format_code(code_line, language, current_indent_level)
              puts formatted_line
              sleep(speed * 3)
            end
            code_buffer.clear
            current_indent_level = 0
            puts "\n"
          else
            puts "\n"
          end
          in_code_block = !in_code_block
          next
        end

        if in_code_block
          code_buffer << line
        else
          words = line.split(' ')
          current_line_length = @left_padding
          words.each do |word|
            raise Interrupt if @typing_interrupted

            if current_line_length + word.length + 1 > @terminal_width - @right_margin
              print "\n#{padding}"
              current_line_length = @left_padding
            end

            word.each_char do |char|
              raise Interrupt if @typing_interrupted
              print char
              sleep(speed)
              $stdout.flush
            end

            print ' '
            current_line_length += word.length + 1
            sleep(speed)
          end
          puts
        end
      end

    rescue Interrupt
      @typing_interrupted = true
      puts "\n#{padding}[Response interrupted]"
      return
    end
    puts
  end
end

Signal.trap('INT') do
  if defined?($chat) && $chat.instance_variable_defined?(:@typing_interrupted)
    $chat.instance_variable_set(:@typing_interrupted, true)
  end
end

if __FILE__ == $0
  $chat = AIChat.new
  $chat.start
end