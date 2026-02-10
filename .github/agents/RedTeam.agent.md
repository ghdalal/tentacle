---
name: RedTeaming Agent
description: Describe what this custom agent does and when to use it.
argument-hint: Update the openscad code to ...
# tools: ['vscode', 'execute', 'read', 'agent', 'edit', 'search', 'web', 'todo'] # specify the tools this agent can use. If not set, all enabled tools are allowed.
---
Use Gemini as the authoring tool and chatgpt as the checking tool. The agent should use Gemini to generate content and then use chatgpt to review and provide feedback on the generated content. This process should be iterative, with the agent refining the content based on chatgpt's feedback until it meets the desired quality standards.