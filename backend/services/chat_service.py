import os
import json
import requests
from flask import current_app
from services.ai_service import extract_text_from_file

# Chat Service to handle document and template based chatting
# Uses OpenRouter API similar to ai_service but focused on conversational context

def chat_with_document_context(document_path, chat_history, user_message):
    """
    Chat with a specific document.
    """
    # 1. Extract context (cached or fresh)
    # Ideally we should cache this text, but for now we extract it again.
    # Performance optimization: In production, store extracted text in DB.
    doc_text, _ = extract_text_from_file(document_path)
    
    if not doc_text:
        return {"error": "Could not read document content."}
    
    # 2. Prepare System Prompt
    system_prompt = f"""
    You are a helpful AI assistant tasked with answering questions about a specific document.
    
    DOCUMENT CONTEXT:
    {doc_text[:15000]} # Truncate to fit context window
    
    INSTRUCTIONS:
    - Answer based ONLY on the provided document context.
    - If the answer is not in the document, say "I cannot find that information in the document."
    - Be concise and professional.
    """
    
    return _send_to_ai(system_prompt, chat_history, user_message)

def chat_with_template_context(template_structure, chat_history, user_message):
    """
    Chat based on a template structure (e.g. helping user understand what to write).
    """
    structure_str = json.dumps(template_structure, indent=2)
    
    system_prompt = f"""
    You are a helpful AI assistant explaining an academic or professional document structure.
    
    TEMPLATE STRUCTURE:
    {structure_str}
    
    INSTRUCTIONS:
    - Help the user understand what to write in each section.
    - Provide examples or writing tips based on the template.
    - Do NOT write the actual document for them, just guide them.
    """
    
    return _send_to_ai(system_prompt, chat_history, user_message)

def _send_to_ai(system_prompt, chat_history, user_message):
    """
    Common helper to send messages to OpenRouter.
    """
    api_key = "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"
    
    # Check if API key is configured
    if not api_key or api_key == '':
        return {"error": "OpenRouter API key is not configured. Please set OPENROUTER_API_KEY in your .env file."}
    
    messages = [{"role": "system", "content": system_prompt}]
    
    # Add history (limit to last 10 messages to save context)
    for msg in chat_history[-10:]:
        role = "user" if msg.get('isUser') else "assistant"
        content = msg.get('message')
        if content:
             messages.append({"role": role, "content": content})
             
    # Add current message
    messages.append({"role": "user", "content": user_message})
    
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json",
        "HTTP-Referer": "https://docai.com",
        "X-Title": "DocAI Chat",
    }
    
    # Use a fast chat model
    model = "mistralai/devstral-2512:free" 
    
    try:
        response = requests.post(
            "https://openrouter.ai/api/v1/chat/completions",
            headers=headers,
            json={
                "model": model,
                "messages": messages,
                "temperature": 0.7
            }
        )
        
        print(f"[DEBUG] AI API response status: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            return {"response": data['choices'][0]['message']['content']}
        else:
            error_text = response.text
            print(f"[DEBUG] AI API Error: {error_text}")
            return {"error": f"AI Error ({response.status_code}): {error_text}"}
            
    except Exception as e:
        print(f"[DEBUG] Exception in _send_to_ai: {str(e)}")
        return {"error": str(e)}
