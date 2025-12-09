---
layout: post 
title: "Linking MLFlow to Databricks Hosted"
date: 2025-12-03
categories: [Data Engineering, Databricks]
tags: [databricks]
mermaid: true
---
This is a quick note to myself for future use cases. Often times, when devloping locally, i tend to point to a local MLFlow instance and then when deploying to upper environments, its redirected to a Databricks hosted MLFlow endpoint. 

For the most part this is fairly straightforward and databricks has good documentation [here](https://docs.databricks.com/aws/en/mlflow3/genai/getting-started/connect-environment?language=.env+File).

For a quick verification test, here is my sample code

```python
import asyncio
import os

import mlflow
from dotenv import load_dotenv
from openai import AsyncAzureOpenAI

load_dotenv(".env.databricksmlflow")              # file in cwd


mlflow.openai.autolog()

client = AsyncAzureOpenAI(
    azure_endpoint=AZURE_OPENAI_ENDPOINT,
    api_key=AZURE_OPENAI_API_KEY,
    api_version=AZURE_OPENAI_API_VERSION,
)
print(f"[diag] Azure OpenAI configured: {AZURE_OPENAI_DEPLOYMENT}")

MESSAGES = [
    {"role": "system", "content": "You are a helpful assistant."},
    {"role": "user", "content": "Hello!"},
]


async def main():
    resp = await client.chat.completions.create(
        model=AZURE_OPENAI_DEPLOYMENT,
        messages=MESSAGES,
    )
    print(resp.choices[0].message.content)


if __name__ == "__main__":
    asyncio.run(main())


```

The environment files looks like this

``` bash
AZURE_OPENAI_API_KEY=xxx
AZURE_OPENAI_ENDPOINT=https://xx.azure.com/
AZURE_OPENAI_API_VERSION=xx
AZURE_OPENAI_DEPLOYMENT_NAME=xx

# MLFLOW log to databricks
DATABRICKS_TOKEN=xxx-3
DATABRICKS_HOST=https://xx.azuredatabricks.net
MLFLOW_TRACKING_URI=databricks
MLFLOW_REGISTRY_URI=databricks-uc
MLFLOW_EXPERIMENT_ID=123
```

And you should see this in your databricks experiment!

![Databricks MLFlow](/assets/images/data-eng-databricks-mlflow-traces.png)
