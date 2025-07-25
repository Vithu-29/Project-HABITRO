import requests
import json
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .models import Quiz, UserProgress
from .serializers import QuizSerializer, UserProgressSerializer
from rewards.models import Reward
from rest_framework.permissions import IsAuthenticated
from decouple import config

class GenerateQuizView(APIView):
    permission_classes = [IsAuthenticated]
    
    def post(self, request):
        url = "https://openrouter.ai/api/v1/chat/completions"
        headers = {
            "Authorization": f"Bearer {config('OPENROUTER_API_KEY')}", #place openrouter api key inside .env 
            "Content-Type": "application/json",
        }

        prompt = (
            "Generate 10 multiple-choice quiz questions. "
            "Each question should be 6 to 8 words long and have 4 answer options. "
            "Indicate the correct answer clearly. "
            "Respond ONLY in raw JSON format like this:\n\n"
            "[\n"
            "  {\n"
            "    \"question\": \"What is the capital of France?\",\n"
            "    \"options\": [\"Paris\", \"London\", \"Berlin\", \"Madrid\"],\n"
            "    \"answer\": \"Paris\"\n"
            "  },\n"
            "  ...(10 total questions)\n"
            "]"
        )

        payload = {
            "model": "deepseek/deepseek-chat-v3-0324:free",
            "messages": [{"role": "user", "content": prompt}]
        }

        try:
            response = requests.post(url, headers=headers, data=json.dumps(payload))
            response.raise_for_status()  # Raises HTTPError for 4xx/5xx status codes

            data = response.json()
            content = data["choices"][0]["message"]["content"].strip()

            # Clean JSON formatting
            content = content.replace("```json", "").replace("```", "").strip()

            try:
                quizzes = json.loads(content)
                
                # Validate quiz format and save to DB
                for quiz in quizzes:
                    if not all(key in quiz for key in ('question', 'options', 'answer')):
                        raise ValueError("Invalid quiz format")
                        
                    if len(quiz["options"]) != 4:
                        raise ValueError("Each question must have exactly 4 options")

                    Quiz.objects.create(
                        question=quiz["question"],
                        option_1=quiz["options"][0],
                        option_2=quiz["options"][1],
                        option_3=quiz["options"][2],
                        option_4=quiz["options"][3],
                        answer=quiz["answer"]
                    )

                return Response({"message": "Saved to DB successfully"}, status=status.HTTP_201_CREATED)

            except json.JSONDecodeError as e:
                return Response({"error": f"JSON parsing failed: {str(e)}"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
            
            except (KeyError, ValueError) as e:
                return Response({"error": f"Invalid quiz format: {str(e)}"}, status=status.HTTP_400_BAD_REQUEST)

        except requests.exceptions.RequestException as e:
            return Response(
                {"error": f"API request failed: {str(e)}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
            
        except Exception as e:
            return Response(
                {"error": f"Unexpected error: {str(e)}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class GetQuizView(APIView):
    permission_classes = [IsAuthenticated]
    def get(self, request):
        try:
            progress, _ = UserProgress.objects.get_or_create(user=request.user)
            quizzes = Quiz.objects.all()

            if quizzes.count() < progress.current_question_index + 10:
                GenerateQuizView().post(request)  # Generate more quizzes
                quizzes = Quiz.objects.all()  # Refresh queryset

            quiz_batch = quizzes[progress.current_question_index:progress.current_question_index+10]
            serializer = QuizSerializer(quiz_batch, many=True)
            return Response({
                "quizzes": serializer.data,
                "current_question_index": progress.current_question_index
            })
        except Exception as e:
            return Response({"error": str(e)}, status=500)

class UpdateProgressView(APIView):
    permission_classes = [IsAuthenticated]
    def patch(self, request):
        try:
            progress, _ = UserProgress.objects.get_or_create(user=request.user)
            serializer = UserProgressSerializer(progress, data=request.data, partial=True)
            if serializer.is_valid():
                serializer.save()
                return Response(serializer.data)
            return Response(serializer.errors, status=400)
        except Exception as e:
            return Response({"error": str(e)}, status=500)

class AddCoinsView(APIView):
    permission_classes = [IsAuthenticated]
    def post(self, request):
        try:
            if 'coins' not in request.data:
                return Response({"error": "Coins field is required."}, status=400)

            try:
                coins = int(request.data['coins'])
            except (ValueError, TypeError):
                return Response({"error": "Coins must be an integer."}, status=400)

            reward, _ = Reward.objects.get_or_create(user=request.user)
            reward.coins += int(coins)
            reward.save()
            return Response({"message": f"Added {coins} coins!"})
        except Exception as e:
            return Response({"error": str(e)}, status=500)