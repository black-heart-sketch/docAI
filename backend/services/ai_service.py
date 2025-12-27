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

def chunk_text(text, chunk_size=15000):
    """Splits text into chunks of approximately chunk_size characters."""
    return [text[i:i+chunk_size] for i in range(0, len(text), chunk_size)]

def analyze_document(document_id, file_path, template_structure):
    """
    Analyzes the document against the template using OpenRouter AI.
    Handles large documents by chunking and iterative refinement.
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

    # 2. Chunk Text
    chunks = chunk_text(document_text)
    total_chunks = len(chunks)
    print(f"AI Service: Split document into {total_chunks} chunks.")

    api_key = "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"
    if not api_key:
        print("Error: OPENROUTER_API_KEY not set.")
        return {"error": "Server misconfiguration (missing API key)", "analysis_status": "failed"}

    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json",
        "HTTP-Referer": "https://docai.com",
        "X-Title": "DocAI",
    }
    model = "tngtech/deepseek-r1t2-chimera:free"
    
    current_analysis = None
    
    for i, chunk in enumerate(chunks):
        chunk_num = i + 1
        print(f"AI Service: Processing chunk {chunk_num}/{total_chunks}...")
        
        structure_desc = json.dumps(template_structure, indent=2)
        
        # Build Prompt
        if chunk_num == 1:
            # Initial Analysis Prompt
            prompt = f"""
            You are an expert academic and professional document analyzer. 
            Analyze the following document content (Part {chunk_num} of {total_chunks}) against the provided template structure.
            
            TEMPLATE STRUCTURE:
            {structure_desc}
            
            DOCUMENT CONTENT (PART {chunk_num}):
            {chunk}
            
            TASK:
            1. Check if the document makes sense and is well-written for the topic.
            2. Check if it matches the required structure sections. 
               NOTE: Section names in the document may not be exactly the same as the template. Use your judgment to identify corresponding sections.
            3. Evaluate any EXTRA MATERIAL provided by the student that is not in the template. If relevant/valuable, note it in 'general_comments'.
            4. Provide a percentage match score (0-100).
            5. Provide feedback for each expected section.
            
            OUTPUT FORMAT (JSON ONLY):
            {{
                "accuracy_score": <number 0-100>,
                "feedback": {{
                    "<Section Name>": {{"status": "found"|"missing"|"partial", "score": <0-100>, "notes": "<brief comments>"}},
                    ...
                }},
                "general_comments": "<overall assessment, including notes on specific extra material>"
            }}
            """
        else:
            # Refinement Prompt
            previous_result_json = json.dumps(current_analysis, indent=2)
            prompt = f"""
            You are analyzing a large document in parts. 
            Here is the analysis result from the previous {chunk_num - 1} parts:
            {previous_result_json}
            
            Here is the NEXT part of the document (Part {chunk_num} of {total_chunks}):
            {chunk}
            
            TASK:
            Update the existing analysis JSON based on this new content.
            1. If a section was marked 'missing' or 'partial' but is found in this new part (even with a slightly different name), mark it as 'found' and update the score/notes.
            2. If new relevant EXTRA MATERIAL is found, append your observations to 'general_comments'.
            3. Adjust the overall 'accuracy_score' if more requirements are met.
            
            OUTPUT FORMAT: Return the FULL UPDATED JSON only.
            """

        # Call AI
        messages = [{"role": "user", "content": prompt}]
        
        try:
            response = requests.post(
                url="https://openrouter.ai/api/v1/chat/completions",
                headers=headers,
                data=json.dumps({
                    "model": model,
                    "messages": messages,
                    "reasoning": {"enabled": True}, 
                    "response_format": {"type": "json_object"}
                })
            )
            
            if response.status_code != 200:
                print(f"AI API Error (Chunk {chunk_num}): {response.text}")
                # If a chunk fails, we might return partial result or fail. 
                # For now, let's keep previous analysis if available, otherwise fail.
                if current_analysis:
                    print("Returning partial analysis due to error.")
                    break
                else:
                    return {"error": f"AI service failed on chunk {chunk_num}", "analysis_status": "failed"}

            response_json = response.json()
            content = response_json['choices'][0]['message']['content']
            
            # Parse JSON
            try:
                import re
                json_match = re.search(r'\{.*\}', content, re.DOTALL)
                if json_match:
                    current_analysis = json.loads(json_match.group(0))
                else:
                    # Fallback or retry logic could go here. 
                    # For now, print warning and continue if possible
                    print(f"Warning: No JSON found in chunk {chunk_num} response.")
            except Exception as e:
                print(f"Error parsing JSON for chunk {chunk_num}: {e}")
                
        except Exception as e:
             print(f"Exception processing chunk {chunk_num}: {e}")
             if not current_analysis:
                 return {"error": str(e), "analysis_status": "failed"}
             break # Return what we have so far

    # Finalize
    if current_analysis:
        current_analysis['analysis_status'] = 'completed'
        current_analysis['page_count'] = page_count
        return current_analysis
    else:
        return {"error": "Analysis produced no results", "analysis_status": "failed"}
