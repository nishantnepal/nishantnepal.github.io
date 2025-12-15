---
layout: post 
title: "Agentic AI - Cost"
date: 2025-10-06
categories: [Generative AI, Architectural Concerns, Cost]
tags: [gen-ai]
mermaid: true
---
## Intro
Before implementing agents, teams should first deploy simple RAG to establish a baseline for comparison. One of the reasons is, if you are cost conscious, then RAG is the more deterministic LLM pattern where the input(context) to LLM is driven through your vector store. Because the LLM gets context + user question and answers in one call, the cost (or tokens) are also more "deterministic" as show in the below figure ...i.e get nearest "n" searches from vector store and send that to the LLM to get the response.

![RAG Tokens](/assets/images/genai-rag-tokens.gif)

If you switch to using agents, the flow changes. You gain flexibility—your orchestrator starts out “dumb” (unlike RAG, where the first step is always a vector store search), but with access to various tools, it can dynamically decide which methods to call to answer a query (like checking available data dictionaries or invoking specific tools). The tradeoff: increased token usage and cost. For example, in the screenshots, RAG calls are about 2x-3x cheaper than equivalent agentic calls using tools. While token costs are dropping and may not be a deal breaker, if your agent orchestrates a long-running process, the main cost driver will likely be the compute time required to execute the query.

![RAG Tokens](/assets/images/genai-agentic-tokens.gif)

## Summary
The goal isn't to discourage agentic AI, but to emphasize that your use case and expected ROI should drive the decision. Cost matters, but it shouldn't dominate the conversation. What's too expensive for one project may be perfectly reasonable for another if the ROI justifies it. And there are still many ways to optimize costs—prompt refinement, tool caching, token budgets, context pruning, and more.

Beyond optimization, you also need to consider TCO (Total Cost of Ownership). Don't just factor in tokens and infrastructure for the agent itself. Account for the downstream costs of actions your agent executes—SQL queries, API calls, or other compute-intensive tasks. These can add up quickly and often catch teams off guard when they're focused solely on model inference costs.

For example, in a recent implementation, our agent executed SQL queries against a large Databricks schema, with individual queries taking 10-30 minutes to complete. The compute costs for these long-running queries quickly dwarfed the LLM token costs. By isolating agent queries in dedicated Databricks jobs with appropriate security controls, we could accurately track and attribute these infrastructure costs to the total TCO.

