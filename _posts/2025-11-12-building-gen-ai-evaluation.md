---
layout: post 
title: "Agentic AI - Evaluations"
date: 2025-11-12
categories: [Generative AI, Architectural Concerns]
tags: [gen-ai]
mermaid: true
---
## Intro Thoughts

My career has fluctuated between software and data as primary focus areas, with infrastructure and DevSecOps as secondary strengths. While there may be more formal definitions of LLM evaluations, the one that resonates most with me is that it’s essentially software testing for AI models. In software testing—unit, integration, performance, etc.—we verify that deterministic code behaves as expected. LLM evaluation follows the same principle but applied to model behavior: instead of fixed outputs, we give the model test cases as prompts and assess whether the responses are safe, reliable, and correct across many scenarios, using metrics that capture accuracy, consistency, and overall quality.

## How does it work
Imagine this scenario: your LLM app is running on GPT-4.1 and then GPT-5.0 is released. How can you confidently upgrade knowing your users will continue getting the same experience and that your code or workflows won’t inadvertently break?

You could do a quick eyeball check and decide, “Yes, everything looks fine to upgrade.” The screenshot below is real time (with reasoning set to minimal for GPT 5) and you can see a must faster/smoother response for GPT 5 but also given that the pricing for input tokens for GPT 5 is cheaper (yayy - more context window) at the expense of more expensive for output tokens, its definately a consideration for upgrade!

![GPT 4 versus 5](/assets/images/genai-gpt_4_5_comp.gif)


But as a technologist, you know better than to rely on eyeballing such a critical change. If your proposed process looks something like this: you maintain a sample dataset where one column contains the prompts you want to test and the other contains the expected answers (optional). You run this dataset across both models and compare the results. As your system matures—or as you refine your prompts—you add new rows to that dataset so the model is tested against those cases as well -  congratulations...you are performing an evaluation :)

Example, my dataset looks like this if i am testing a Natural Language to SQL use case. The key is to look and idenfity patterns. Maybe it consistently generates SQL that looks correct but doesn’t execute. Maybe it joins the wrong tables or filters on the wrong column names. Maybe it returns a result that’s close but not identical, or it misses edge cases like distinct counts or date calculations. These recurring failure modes help you understand exactly how the model behaves and where prompt or model changes will matter.

![Eval Questions](/assets/images/genai-eval-questions.png)

> Note: The ground truth column can be a string, number or any data type. The reason i have it as a pointer to a file is because in my case, it contains more information that do not cleanly fit into a cell

The next step is running those questions against the LLMs that you want to target and capturing the outputs from the LLMs. If you have a small evaluation dataset, you can manually validate the results but its likely that the eval dataset keeps on growing and you need to start thinking about evaluating advanced options such as "LLM as a judge". 

> You should consider creating an evaluation dataset at the start of the project and keep on expnading that. This is critical. What is not immediately critical at start of project are the advanced patterns such as LLMs as judges and so on. You will get to these eventually.

 With that said, if you are going down the automated route, you end up with code that resembles something like this.

```python
  # Here batch_predict is the function that calls the corresponding LLM and static_context is the retrieved context (think RAG)
  questions = df_raw["question"].tolist()
  pred_41m = batch_predict(generate_with_trace, cfg["deploy_gpt41_mini"], questions, static_context)
  pred_5m = batch_predict(generate_with_trace, cfg["deploy_gpt5_mini"], questions, static_context)
```

Next you pass the results through your "***scorers***". Scorers are the rules or functions that decide how "good" a model's answer is. They take the model's output (and optionally the expected or target response) and return a score - boolean, percentage or numerical metric. Implementation of custom scorers is dependent on the evaluation platform you choose and most platforms also have default scorers you can tap into. In my case, i am using MLFlow but you can find the comparision between some of the common tools below (courtesy of ChatGPT - i have not tested the frameworks below so the this boilerplate warning is valid "***ChatGPT can make mistakes. Check important info.***")

| Framework              | Primary Use Case                                                          | Custom Code Scorers?          | Strengths                                                             | Limitations                                       |
| ---------------------- | ------------------------------------------------------------------------- | ----------------------------- | --------------------------------------------------------------------- | ------------------------------------------------- |
| **MLflow Evaluations** | Production-grade LLM evaluations, model upgrades, reproducible benchmarks | ⭐⭐⭐⭐⭐ Yes                     | Versioning, model registry, traces, dashboards                        | Requires MLflow infra, heavier                    |
| **DeepEval**           | CI/CD, Python-based unit-test style evals                                 | ⭐⭐⭐⭐⭐ Yes (excellent)         | Very flexible, developer-friendly, works like pytest                  | No built-in dashboards                            |
| **Braintrust**         | Continuous evaluation + A/B testing + production analytics                | ⭐⭐⭐⭐ Yes                      | Great UI, experiment management, real-time feedback                   | External service; less governance                 |
| **Ragas**              | RAG-specific metrics                                                      | ⭐⭐ Limited                    | Easy hallucination + relevance metrics                                | Not general-purpose; weak custom scoring          |
| **LangSmith**          | Chain evaluation + tracing                                                | ⭐⭐⭐ Yes                       | Good for LangChain users, strong visualization                        | Best inside LangChain ecosystem                   |
| **Giskard**            | Safety, toxicity, bias, compliance                                        | ⭐⭐⭐ Yes                       | Strong in regulated contexts                                          | Not built for SQL correctness or general tests    |
| **PydanticAI Evals**   | Developer-friendly structured evals using typed models + Python scorers   | ⭐⭐⭐⭐⭐ Yes (simple + powerful) | Schema validation, custom Python scoring, CLI runner, no infra needed | No dashboards, no large-scale experiment tracking |

MLFlow has a list of predefined scorers which can be [found here](https://mlflow.org/docs/3.6.0/genai/eval-monitor/scorers/llm-judge/predefined/#available-scorers)

![Predefined Scorers](/assets/images/genai-mlflow-predefined-scorers.png)

You define your scorers in an object and pass the data to it for evaluation - pretty straightforward

```python
def create_scorers(judge_model: str) -> List:
  #  MLFlow uses LiteLLM for calling different providers. 
  # results_match is a custom scorer
    return [
        Safety(model=judge_model),
        Equivalence(model=judge_model),
        Correctness(model=judge_model),         
        RelevanceToQuery(model=judge_model),            
        results_match,                      
    ]

def eval_and_log(run_name: str, data: pd.DataFrame, scorers) -> Dict[str, Any]:
    with mlflow.start_run(run_name=run_name):
        result = mlflow.genai.evaluate(data=data, scorers=scorers)
        # Remaining code omitted for brevity

# Call the function passing in the required parameters
eval_and_log(f"<MODEL IDENTIFIER>", data_pandas, scorers)
```

Running the above results in this in the UI. 

![Predefined Scorers UI](/assets/images/genai-mlflow-evals_predefined.gif)

Now while this is admittedly better than no evaluations, this is also generic. Only you know what rules and checks apply for your app and use case and every app is different. In my hypothetical scenario of generating SQL from natural language, its the results accuracy that i care about more than the generated SQL because different LLMs can generate different SQL. To achieve that, MLFlow supports custom scorers and in my POC its implemented as shown below - no suprises, its a regular python function that compares the results of the LLM calls against expected values.

```python
@scorer(
    name="ResultsMatch",
    description="Results match expectations.expected_response",
    aggregations=[],
)
def results_match(inputs, outputs, expectations):
    from mlflow.entities import Feedback


    # Get filename from expectations
    json_filename = expectations.get("expected_response")
    if not json_filename:
        return "Fail - missing expectations['expected_response']"

    json_path = Path(json_filename)

    if not json_path.exists():
        return f"Fail - expected file not found: {json_path}"

    # Read the JSON file
    try:
        with json_path.open("r", encoding="utf-8") as f:
            expected_data = json.load(f)
    except (OSError, json.JSONDecodeError) as e:
        return f"Fail - error reading expected JSON: {e}"

    # Compare expected vs actual (pass full objects; helper looks inside "result")
    if not isinstance(outputs, dict):
        return "Fail - outputs is not a dict"

    comparison = compare_counts(expected_data, outputs)
    rationale = (
        comparison
    )

    value = bool(comparison.get("all_match"))
    return Feedback(value=value, rationale="Need to fill this")


```
And this shows up in the UI alongside my other assessments. Nice! Now, depending on the use case, i can create more rules as needed.

![Custom Scorer UI](/assets/images/genai-mlflow-evals_custom.gif)


## Summary
In this article, we walked through why evaluations are essential and, in my opinion, something you should think about right from the start of any LLM project. While I focused on MLflow, you can use whatever framework fits your workflow—but make sure it supports **custom scorers**, because that’s ultimately what makes evaluations adaptable to your specific use case. We also walked through how to implement a custom scorer in MLflow and why that flexibility matters.


## Coming Up Next

In the next post, we'll explore ***Feedback*** as a critical architectural concern when building agentic AI systems.
