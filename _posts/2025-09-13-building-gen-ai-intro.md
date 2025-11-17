---
layout: post 
title: "Introduction to Building Generative AI Products"
date: 2025-09-13
categories: [Generative AI]
tags: [gen-ai, architecture, enterprise-ai, mcp]
---

## The Challenge

Building a compelling generative AI demo is relatively straightforward in 2025. But taking that demo and transforming it into a production-ready, enterprise-grade system? That's where most demos do not go into yet is probably the most important step. I have been diving deeper into building agentic AI systems, but more importantly, seeing how they can fit into an enterprise environment - address the architectural concerns, security requirements, scalability challenges, and operational complexities that emerge when deploying to a production environment.

The goal of this series is to bridge that gap—to cover the practical architectural patterns and engineering practices needed to build enterprise-ready generative AI products. This is also a place for me to gather and refine my thoughts as I navigate this evolving landscape.


## High Level Architecture

The diagram below represents the overall high-level architecture we'll be working with throughout this series. The goal is **not the** LLM content or the code - rather its the process of scaling this.

![High-level architecture diagram showing MCP servers, web application, and Azure OpenAI integration](/assets/images/genai-highlevel-arch.png)


## Core Components

From a components perspective, these are the building blocks of our architecture:

**1. Remote MCP Servers (Model Context Protocol)**

Two or more remote MCP servers that provide specialized tools and contextual resources to our AI agents. Each server is secured using OAuth 2.0, ensuring that only authenticated and authorized clients can access sensitive enterprise data and operations. MCP servers act as the bridge between your AI agents and your existing enterprise systems—databases, APIs, internal tools, and domain-specific knowledge bases.

**2. Agentic Web Application**

A web application that hosts an intelligent chat UI, also secured using OAuth for user authentication. The application dynamically queries one or more MCP servers based on the user's intent, retrieves the necessary tools and resources, orchestrates the AI agent's workflow, and displays results back to the user in a conversational interface. This component handles:
- User session management
- Agent orchestration and tool selection
- Response streaming and rendering
- Error handling and fallback strategies

**3. Azure OpenAI Service**

For this series, I'll be using Azure OpenAI with the GPT-5 mini model as our large language model.

## Why This Architecture?

This architecture addresses several enterprise concerns:

- **Security**: OAuth at every layer ensures proper authentication and authorization
- **Modularity**: MCP servers can be developed and scaled independently
- **Flexibility**: New capabilities can be added by spinning up new MCP servers
- **Governance**: Centralized control over what data and tools the AI can access
- **Scalability**: Each component can scale based on demand

## Warning
Comparing Agentic AI (multi or single) with simple RAG is not exactly a no-brainer of Agentic AI winning every time. The old saying of "depends on use case" very much applies. Building an agentic AI system does add development complexity and in a scenario where remote MCP servers are involved, you do need to factor in latency and other concerns as well.

## Coming Up Next

In the next post, we'll dive deeper into setting up remote MCP servers and clients.


