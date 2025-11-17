---
layout: post 
title: "Architectural Concerns - Cost"
date: 2025-10-06
categories: [Generative AI, Architectural Concerns, Cost]
tags: [gen-ai]
mermaid: true
---
## Cost in RAG
When dealing with RAG only, for most cases, the flow is normally

```mermaid
 flowchart TD

    A[User Query
    ---
    User asks a question in natural language]
        --> 
    B[Preprocess and Normalize Query
    ---
    Clean and standardize the query for embedding]

    B --> 
    C[Embed Query
    ---
    Convert the query into a vector representation]

    C --> 
    D[Vector Store Search Top K
    ---
    Search vector database for similar document chunks]

    D --> 
    E[Retrieve Relevant Documents
    ---
    Fetch the text linked to the retrieved vectors]

    E --> 
    F[Construct Prompt
    ---
    Combine query and retrieved context into a prompt]

    F --> 
    G[LLM Generates Answer
    ---
    Model uses context to produce a grounded response]

    G --> 
    H[Return Answer to User
    ---
    Final answer delivered back to the user]



```

Because the LLM gets context + user question and answers in one call, the cost (or tokens) are also more "deterministic" as show in the below figure ...i.e get nearest "n" searches from vector store and send that to the LLM to get the response.

![RAG Tokens](/assets/images/genai-rag-tokens.gif)

If i switch to using agents, then things look different. Yes, i gain flexibility where my orchestrator is "dumb" initially (in RAG, your first step is always calling the vector store) but with the tools at its disposal, it can dynamically call/enlist methods that it needs to help answer - what data dictionaries exist, what tools can i call etc. But, this comes at the expense of more tokens/cost. For example, in the two screenshots, both calls for RAG are cheaper approximately 65% over equivalent calls using tools. 

![RAG Tokens](/assets/images/genai-agentic-tokens.gif)

With that said, there are definately optimizations that can be made to reduce costs - prompt optimizations, tool caching, token budgets, context pruning and others.

## Coming Up Next

In the next post, we'll look into ***Security*** as an architectural concern in the context of an agent.
