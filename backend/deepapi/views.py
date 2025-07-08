import json
import requests
from decouple import config  # Add this import
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import re  # Import regular expression module to clean up the response
from rest_framework.decorators import api_view,permission_classes
from rest_framework.permissions import IsAuthenticated


@api_view(['POST'])
@permission_classes([IsAuthenticated])

def analyze_habit(request):
    print("User:", request.user)
    if request.method == "POST":
        data = json.loads(request.body)
        habit_text = data.get("habit", "")

        if not habit_text:
            return JsonResponse({"error": "No habit provided"}, status=400)

        # OpenRouter API Endpoint
        url = "https://openrouter.ai/api/v1/chat/completions"

        headers = {
            "Authorization": f"Bearer {config('OPENROUTER_API_KEY')}",
            "Content-Type": "application/json"
        }

        payload = {
            "model":"deepseek/deepseek-chat-v3-0324:free",#"model": "deepseek/deepseek-r1-zero:free",  # Using DeepSeek R1 Zero
            "messages": [
                {"role": "system", "content": "You are an AI that classifies habits as 'Good' or 'Bad'."},
                {"role": "user", "content": f"Analyze this habit and classify it as 'Good' or 'Bad': {habit_text}"}
            ]
        }

        # Debugging: Print the API key and the payload being sent
       
        

        try:
            response = requests.post(url, headers=headers, json=payload)
            print("OpenRouter Status Code:", response.status_code)
            print("OpenRouter Response Text:", response.text)

            
            # Debugging: Check the status code and response data
              # Debug: print the status code
            response_data = response.json()
             # Debug: print the response data

            if "choices" in response_data:
                # Extract the result and remove LaTeX formatting
                result = response_data["choices"][0]["message"]["content"].strip()
                match = re.search(r"\b(Good|Bad)\b", result, re.IGNORECASE)
                if match:
                    cleaned_result = match.group(1).capitalize()
                else:
                    cleaned_result = "Unknown"


                # Clean LaTeX formatting (e.g., \boxed{Bad} becomes Bad)
                #cleaned_result = re.sub(r'\\boxed\{(.*?)\}', r'\1', result)

                return JsonResponse({"habit": habit_text, "classification": cleaned_result})

            return JsonResponse({"error": "Failed to get response from OpenRouter"}, status=500)

        except Exception as e:
            import traceback
            traceback.print_exc()
            print(f"Error in analyze_habit: {e}")#print(f"Error: {str(e)}")  # Debug: print the error message
            return JsonResponse({"error": str(e)}, status=500)

    return JsonResponse({"error": "Invalid request method"}, status=405)





# Define the endpoint to generate dynamic questions
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def generate_dynamic_questions(request):
    if request.method == "POST":
        try:
            data = json.loads(request.body)
            habit_name = data.get("habit").lower()
            habit_type = data.get("habit_type").lower()  # good or bad
            print("habit name = "+habit_name+ " "+ "habit type = "+ habit_type)

            if habit_type == "good":
                system_prompt = (
                    f"IMPORTANT: You are a POSITIVE REINFORCEMENT coach. The user's habit '{habit_name}' is DEFINITELY GOOD. "
                    f"Generate exactly 4 short questions to help strengthen this positive habit. "
                    f"RULES:\n"
                    f"1. NEVER suggest reducing/stopping this habit\n"
                    f"2. Focus ONLY on benefits, enjoyment, and consistency\n"
                    f"3. Questions must be 100% positive\n"
                    f"4. Format as numbered list with no other text\n\n"
                    f"Example for 'reading books':\n"
                    f"1. What do you enjoy most about reading?\n"
                    f"2. How has reading improved your life?\n"
                    f"3. What's your favorite time/place to read?\n"
                    f"4. How could you make reading even more enjoyable?\n\n"
                    f"Now generate for '{habit_name}':\n"
                    f"1. "
                )
            else:
                system_prompt = (
                    f"You're a helpful coach. The user is trying to quit or reduce a bad habit: '{habit_name}'. "
                    f"Generate 4 short, personalized questions that help the user reflect, reduce, or quit the habit gradually. "
                    f"Do not include explanations. Just list:\n1. Question...\n2. Question...\n3. Question...\n4. Question..."
                )


            payload = {
                "model":"deepseek/deepseek-chat-v3-0324:free",
                "messages": [
                    {"role": "system", "content": system_prompt}
                ],
                "temperature": 0.5
            }

            headers = {
                "Authorization": f"Bearer {config('OPENROUTER_API_KEY')}",
                "Content-Type": "application/json"
            }

            # Send the request to the AI model
            response = requests.post("https://openrouter.ai/api/v1/chat/completions", headers=headers, json=payload)
            ai_response = response.json()["choices"][0]["message"]["content"]

            # Extract the questions from the AI response using regex
            import re
            questions = re.findall(r"\d+\.\s*(.+)", ai_response)
            return JsonResponse({"dynamic_questions": questions})

        except Exception as e:
            return JsonResponse({"error": str(e)}, status=500)

    return JsonResponse({"error": "Invalid request method"}, status=405)