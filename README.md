# Terminal-AI-Chat  
**GitHub Repository**: [1611-Developer/Terminal-AI-Chat](https://github.com/1611-Developer/Terminal-AI-Chat)  

---

## About  
**Terminal-AI-Chat** is a terminal-based AI chat application written in Ruby. It allows users to interact with an AI assistant through the command line. The application integrates with the Anthropic Claude API to provide advanced conversational capabilities.  

---

## Features  
- **Terminal-Based Chat**: A lightweight and interactive chat experience directly in the terminal.  
- **Claude API Integration**: Uses the Anthropic Claude API for generating AI responses.  
- **Code Formatting**: Supports formatting for Ruby and C-style code blocks in the AI's responses.  
- **Conversation History**: Tracks the conversation to ensure context is maintained between messages.  
- **Interruptible Responses**: Allows users to interrupt long AI responses using `Ctrl+C`.  
- **Command Support**:  
  - `exit`: Quit the application.  
  - `clear`: Clear the current conversation history.  

---

## Installation  

### Prerequisites  
- **Ruby**: Version 2.7 or higher is required.  
- **Anthropic Claude API Key**: Obtain an API key from [Anthropic](https://www.anthropic.com/).  

### Steps  
1. Clone the repository:  
   ```bash
   git clone https://github.com/1611-Developer/Terminal-AI-Chat.git
   cd Terminal-AI-Chat
   ```  

2. Install necessary gems:  
   ```bash
   gem install json readline
   ```  

3. Run the application:  
   ```bash
   ruby chat.rb
   ```  

---

## Usage  

1. **Start the Application**: Run `ruby chat.rb` in the terminal.  
2. **Enter API Key**: Input your Anthropic Claude API key when prompted.  
3. **Interact with the AI**: Type your messages and press Enter to receive AI responses.  
4. **Commands**:  
   - Type `exit` to quit the application.  
   - Type `clear` to reset the conversation history.  
5. **Interrupt Responses**: Press `Ctrl+C` to stop long AI responses.  

---

## Example Interaction  

```bash
$ ruby chat.rb

               AI Chat
               Commands: 'exit' to quit, 'clear' to reset conversation
               Press Ctrl+C to stop the current response

Enter your Anthropic API key: <your-api-key>

               Claude configured successfully!

You: Hello, AI!
               Thinking...
AI: Hello! How can I assist you today?

You: Write me a Ruby method to calculate an average.
               Thinking...
AI:
def calculate_average(numbers)
  sum = numbers.reduce(0) { |acc, num| acc + num }
  average = sum.to_f / numbers.length
  average.round(2)
end
```

---

## Repository Structure  

```plaintext
Terminal-AI-Chat/
├── chat.rb       # Main application file
├── README.md     # Documentation file
```

---

## Contributing  

Contributions are welcome! To contribute:  
1. Fork the repository.  
2. Create a new branch for your feature or fix.  
3. Submit a pull request explaining your changes.  

---

## License  

This project is open-source and available under the [MIT License](LICENSE).  

--- 

## Contact  
For any issues or suggestions, please open an issue in the repository: [Issues](https://github.com/1611-Developer/Terminal-AI-Chat/issues).
