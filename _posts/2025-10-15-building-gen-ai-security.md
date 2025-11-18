---
layout: post 
title: "Agentic AI - Security"
date: 2025-10-15
categories: [Generative AI, Architectural Concerns]
tags: [gen-ai]
mermaid: true
---
## Intro Thoughts
When we think of data, its broadly into two categories

#### 1. ***Unstructured Data*** : 
This is data that LLMs are very capable in parsing and understanding. These are your pdfs, images, chat messages and other data that does not follow a predefined format or data model. <br/> <br/>
The security model for these kind of data is relatively straightforward. People have access or they don't. For a bit more complex use-cases (think sharepoint folders), some folks have admin roles while others have read-only roles. What is not typical, unless you are in a very strange situation, is that some folks have access to only some pages in a pdf or can watch only upto "x" meetings of a recording and the remaining pages or recordings need higher security. Hence, when modeling from a security perspective, you can then have the users into a "group" and use the group's app id as the agent's (persona) id that is accessing the backend store with read access. Its relatively simple and effective.

#### 2. ***Structured Data*** : 
THis is data that is organized in a predefined format and for the most part, fits neatly into tables with rows and columns. These are data that are stored in spreadsheets, relational or document databases, financial transactions etc. <br/> <br/>

The security model for structured is more complex and nuanced. These data structures have probably been in places for years and decades and support varying degree of roles. For example in relational databases, its common to have permissions for read, varied permissions on execution of stored procedures, row level security (which rows an user can see), columns masking (protecting specific fields). The question then becomes, what is the persona (or permission level) that the agent is built for? If the agent's persona is that of a privileged user then you have effectively opened a backdoor into your data where someone who may not have permissions on all the data when querying through other channels now has acess to that data through the agent. If the agent's persona is that of a regular user, the usability of your agent may be impacted. There is no easy answer here and it really depends on the use case.

## Solution
The common pattern for agentic AI apps and MCP seems to be OAuth 2.1. At a high level, this means we take the roles/permissions of the individual user and intersect them with the roles/permissions of the agent, and that intersection should serve as the baseline security. This is probably easier said than done, in my opinion.

It is far more feasible if the end-to-end source-to-target systems are OAuth-compliant. In that case, I can take the user ID from the diagram below and pass it—along with the correct scopes—to the downstream data store while authenticating as the user, relying on the downstream system to enforce authorization. But in enterprise environments, where there are many systems that are not OAuth-compliant, this kind of integration breaks down. Chances are that your on-premise oracle or sql server may not support OAuth and rather you need to connect via basic credentials (username and password). How that is handled will be dependent on the use case.

In those situations, it becomes the responsibility of the MCP server to enforce authorization rather than the front-end application. The front-end’s role is to authenticate the user and pass the appropriate token and scopes to the MCP layer. From there, the MCP server ensures that the correct authorization rules are applied before interacting with downstream systems.

![High-level architecture diagram showing MCP servers, web application, and Azure OpenAI integration](/assets/images/genai-highlevel-arch.png)

For the example above, once the user has been authenticated and the information passed with every call to the backend MCP servers, its upto the Synthea and Tracking MCP servers to enforce authorization. So if user ***Test User 1*** has access to execute SQL using a tool, the response will be this

![Tool Call](/assets/images/genai-tool-call-1.gif)

> Note, the above code and chain of tool calls is not optimized and intent is to show a successful tool call

Now for the same call, but with a different user ***Test User 2***, while the user can query for the data dictionaries etc, he/she are prohibited from calling the tool through authorization from the MCP tool.

![Tool Call](/assets/images/genai-tool-call-3-fail.gif)


### Side Note
Due to the non-deterministic nature of LLMs, even with identical inputs and the same model, the responses can vary in efficiency. As demonstrated below, the LLM may generate equivalent results while consuming fewer tokens.

![Tool Call](/assets/images/genai-tool-call-2.gif)


## Coming Up Next

In the next post, we'll explore ***Observability*** as a critical architectural concern when building agentic AI systems.
