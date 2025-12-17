import os
import json
import requests
import pypdf
from flask import current_app

def extract_text_from_file(file_path):
    """Extracts text and page count from PDF or Text files."""
    text = ""
    page_count = 0
    try:
        if file_path.endswith('.pdf'):
            reader = pypdf.PdfReader(file_path)
            page_count = len(reader.pages)
            for page in reader.pages:
                text += page.extract_text() + "\n"
        else:
            # Assume text file
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                text = f.read()
            # Estimate pages for text files (e.g., 500 words per page)
            words = len(text.split())
            page_count = max(1, words // 500)
    except Exception as e:
        print(f"Error extracting text: {e}")
        return None, 0
    return text.strip(), page_count

def analyze_document(document_id, file_path, template_structure):
    """
    Analyzes the document against the template using OpenRouter AI.
    """
    print(f"AI Service: Starting analysis for document {document_id}...")
    
    # 1. Extract Text
    document_text, page_count = extract_text_from_file(file_path)
    if not document_text:
        return {
            "error": "Could not extract text from document.",
            "analysis_status": "failed"
        }
    
    print(f"AI Service: Document has {page_count} pages.")

    # 2. Prepare Prompt
    structure_desc = json.dumps(template_structure, indent=2)
    prompt = f"""
    You are an expert academic and professional document analyzer. 
    Analyze the following document content against the provided template structure.
    
    TEMPLATE STRUCTURE:
    {structure_desc}
    
    DOCUMENT CONTENT:
    {document_text[:10000]}  # Truncate if too long to fit context, adjust as needed
    
    TASK:
    1. Check if the document makes sense and is well-written for the topic.
    2. Check if it matches the required structure sections.
    3. Provide a percentage match score (0-100).
    4. Provide feedback for each expected section.
    
    OUTPUT FORMAT (JSON ONLY):
    {{
        "accuracy_score": <number 0-100>,
        "feedback": {{
            "<Section Name>": {{"status": "found"|"missing"|"partial", "score": <0-100>, "notes": "<brief comments>"}},
            ...
        }},
        "general_comments": "<overall assessment>"
    }}
    """

    api_key = "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"
    if not api_key:
        print("Error: OPENROUTER_API_KEY not set.")
        return {"error": "Server misconfiguration (missing API key)", "analysis_status": "failed"}

    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json",
        "HTTP-Referer": "https://docai.com", # Required by OpenRouter
        "X-Title": "DocAI",
    }

    model = "tngtech/deepseek-r1t2-chimera:free"

    # 3. Call AI API (Step 1: Get Reasoning/Initial Response)
    # Using the user's requested scaffolding style
    
    messages = [
        {"role": "user", "content": prompt}
    ]

    try:
        # First call with reasoning enabled
        response = requests.post(
            url="https://openrouter.ai/api/v1/chat/completions",
            headers=headers,
            data=json.dumps({
                "model": model,
                "messages": messages,
                "reasoning": {"enabled": True}
            })
        )
        
        if response.status_code != 200:
            print(f"AI API Error (Step 1): {response.text}")
            return {"error": "AI Service unavailable", "analysis_status": "failed"}

        response_json = response.json()
        assistant_message = response_json['choices'][0]['message']
        
        # If the model didn't return the final answer yet or we want to force 'thinking',
        # we can do the second step. However, for this task, usually one shot is enough 
        # unless we specifically need to "continue" reasoning.
        # The user's scaffolding implies a 2-step process to ensure "Think carefully".
        
        # Prepare for Step 2 (Confirmation/Refinement) if needed, 
        # OR just parse the result if it's already there.
        # Given the "exacto" model and "reasoning", let's attempt to parse the content directly first.
        # If it's empty or purely reasoning, we might need step 2.
        
        content = assistant_message.get('content', '')
        
        # Attempt to find JSON in the content
        try:
            # Simple cleanup to find JSON block
            import re
            json_match = re.search(r'\{.*\}', content, re.DOTALL)
            if json_match:
                result_json = json.loads(json_match.group(0))
                # Add status
                result_json['analysis_status'] = 'completed'
                return {
                    "analysis_result": result_json, 
                    "analysis_status": "completed",
                    "page_count": page_count
                }
            else:
                # If no JSON found, maybe it needs the second step prompts?
                # Let's try the user's scaffolding exactly.
                pass 
        except:
             pass

        # Step 2: "Are you sure? Think carefully." strategy as requested
        # Preserve reasoning details if present
        new_messages = [
            {"role": "user", "content": prompt},
             {
                "role": "assistant",
                "content": assistant_message.get('content'),
                "reasoning_details": assistant_message.get('reasoning_details') 
            },
            {"role": "user", "content": "Are you sure? Provide the final JSON output now."}
        ]
        
        response2 = requests.post(
            url="https://openrouter.ai/api/v1/chat/completions",
            headers=headers,
            data=json.dumps({
                "model": model,
                "messages": new_messages,
                "reasoning": {"enabled": True},
                "response_format": {"type": "json_object"} # Force JSON on step 2
            })
        )

        if response2.status_code != 200:
            print(f"AI API Error (Step 2): {response2.text}")
            return {"error": "AI Service error in step 2", "analysis_status": "failed"}

        response2_json = response2.json()
        final_content = response2_json['choices'][0]['message']['content']
        
        # Parse Final JSON
        result_data = json.loads(final_content)
        return {
            "analysis_result": result_data,
            "analysis_status": "completed",
            "page_count": page_count
        }

    except Exception as e:
        print(f"AI Analysis Exception: {e}")
        return {
            "error": f"Analysis failed: {str(e)}",
            "analysis_status": "failed"
        }
