import json
import requests
from decouple import config  # Add this import
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from .models import Task,Habit
import uuid
from datetime import timedelta, date,datetime
from rest_framework.views import APIView
from .serializers import HabitSerializer
from rest_framework.response import Response
from rest_framework.decorators import api_view,permission_classes
from rest_framework.permissions import IsAuthenticated
from rewards.models import  Reward  # Add Reward to imports


##from rest_framework import status





###########################################################################################################
                                    ## analyze response ##

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def analyze_responses(request):
    if request.method != "POST":
        return JsonResponse({"error": "Invalid request method"}, status=405)

    try:
        data = json.loads(request.body)
        responses = data.get("responses", {})
        regenerate = data.get("regenerate", False)
        print(f"Regenerate value: {regenerate}")

        


        if not responses:
            return JsonResponse({"error": "No responses provided"}, status=400)

        # Required inputs
        habit_name = responses.get("habit_name", "bad habit")
        duration_str = responses.get("duration", "1")

        try:
            days_to_quit = int(duration_str)
        except (ValueError, TypeError):
            days_to_quit = 1
        print(days_to_quit)

        # Optional but useful
        obstacle = responses.get("obstacle") or responses.get("challenge", "Not specified")
        motivations = responses.get("motivation") or responses.get("reason", "Not specified")
        quantity_per_day = responses.get("quantity_per_day", 3)

        # NEW: dynamic Q&A list
        dynamic_answers = responses.get("dynamic_answers", [])
        print("\n==== DYNAMIC ANSWERS ====")  # For clarity in terminal
        print(json.dumps(dynamic_answers, indent=2))  # Pretty-print JSON

        # SYSTEM PROMPT
        system_prompt = (
             "You are an AI habit transformation coach helping users either quit bad habits or build good ones. "
            "The user has entered a habit: {habit_name}. Generate a personalized task plan over {days} days.\n"
            "Each day should have exactly 3 short, actionable tasks.\n"
            "IMPORTANT RULES FOR TASK GENERATION:\n"
            "1. All tasks must be unique - no repeating or similar tasks across days\n"
            "2. Tasks should show logical progression (gradually harder/easier depending on habit type)\n"
            "3. Each task should be distinct and address different aspects of the habit\n"
            "\n"
            "Tasks must:\n"
            "- Gradually reduce the bad habit if it's harmful (e.g., reduce smoking from X/day to 0).\n"
            "- Gradually increase effort for good habits (e.g., increase reading from 2 pages to 20).\n"
            "- Incorporate tasks supporting user's motivation (e.g., if motivation is health, include light workouts).\n"
            "- Tasks should be relevant to the user's trigger situations.\n"
            "- Never include 'repeat previous task' or similar instructions\n"
            "\n"
            "Return the output in this format:\n"
            "Day 1:\n1. Unique task one\n2. Unique task two\n3. Unique task three\nDay 2:\n... up to Day {days}"
        ).format(habit_name=habit_name, days=days_to_quit)

        # USER PROMPT
        user_prompt = (
            f"Habit: {habit_name}\n"
            f"Days committed: {days_to_quit}\n"
            f"Trigger situations: {obstacle}\n"
            f"Motivations: {motivations}\n"
        )
        
        
        if regenerate:
         user_prompt += "\nNote: The user was not satisfied with the previous plan. Please regenerate a new and different task plan.\n"

        if quantity_per_day:
            user_prompt += f"Current quantity per day: {quantity_per_day}\n"

        if dynamic_answers:
            user_prompt += "\nAdditional user responses:\n"
            for pair in dynamic_answers:
                q = pair.get("question", "").strip()
                a = pair.get("answer", "").strip()
                if q and a:
                    user_prompt += f"- {q}: {a}\n"


        

        # AI Payload
        payload = {
            "model":"deepseek/deepseek-chat-v3-0324:free",
            "messages": [
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt}
            ],
            "temperature": 0.8
        }

        headers = {
            "Authorization": f"Bearer {config('OPENROUTER_API_KEY')}",
            "Content-Type": "application/json"
        }

        # Call OpenRouter
        response = requests.post("https://openrouter.ai/api/v1/chat/completions", headers=headers, json=payload)
        response_data = response.json()
        print(response_data)

        if "choices" in response_data:
            ai_text = response_data["choices"][0]["message"]["content"].strip()
            tasks = extract_tasks(ai_text, days_to_quit)

            return JsonResponse({
                "responses": responses,
                "tasks": tasks,
                "total_days": days_to_quit,
                "total_tasks": len(tasks),
                "tasks_per_day": 3
            })

        return JsonResponse({"error": "Failed to get response from OpenRouter"}, status=500)

    except Exception as e:
        import traceback
        traceback.print_exc()
        return JsonResponse({"error": str(e)}, status=500)

###########################################################################################################
                                    ## extract tasks ##
                                    ######################
                                    ######################
                                    #changed code#########

def extract_tasks(text, expected_days):
    import re

    def clean_text(text):
        text = re.sub(r"[*_~`]+", "", text)
        text = re.sub(r"[^a-zA-Z0-9\s,.'\-]", "", text)
        text = re.sub(r"\s+", " ", text)
        return text.strip()

    task_list = []
    day_pattern = re.compile(r"Day\s*(\d+):(.+?)(?=\nDay\s*\d+:|\Z)", re.DOTALL)
    task_pattern = re.compile(r"\d+\.\s*(.*?)(?=\n\d+\.|\Z)", re.DOTALL)

    for day, content in day_pattern.findall(text):
        tasks = task_pattern.findall(content)
        for task in tasks:
            clean_task = task.strip()
            clean_task = re.sub(r"\*\*Day\s*\d+\:\*\*", "", clean_task)
            clean_task = clean_task.strip()
            clean_task = clean_text(clean_task)
            if clean_task and "repeat last task" not in clean_task.lower():
                task_list.append({"task": clean_task, "isCompleted": False})

    last_task = task_list[-1] if task_list else {"task": "Generic fallback task", "isCompleted": False}
    while len(task_list) < expected_days * 3:
        task_list.append(last_task)

    return task_list[:expected_days * 3]

###########################################################################################################
                                    ## save tasks ##
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def save_tasks(request):
    if request.method == 'POST':
        try:
            print("Received request to save tasks")  # Debug
            data = json.loads(request.body)
            print(f"Received data: {data}")  # Debug
            habit_name = data.get('habit_name')
            habit_type = data.get('habit_type')
            tasks = data.get('tasks', [])

            print(f"Creating habit: {habit_name}, {habit_type}")  # Debug
            print(f"With tasks: {tasks}")  # Debug

            # Create a new habit with a UUID
            habit = Habit.objects.create(
                id=uuid.uuid4(),
                name=habit_name,
                type=habit_type,
                user=request.user  # ✅ this links the habit to the logged-in user
            )


            ###*************************###
            tasks_per_day = 3
            total_days = len(tasks) // tasks_per_day
            today = date.today()


            for day in range(total_days):
                task_date = today + timedelta(days=day)
                for i in range(tasks_per_day):
                    task_index = day * tasks_per_day + i
                    if task_index < len(tasks):
                        Task.objects.create(
                            habit_id=habit,
                            task=tasks[task_index]['task'],
                            isCompleted=tasks[task_index].get('isCompleted', False),
                            date=task_date
                        )

            ###************************####

            # Save new tasks
           ## for idx, task in enumerate(tasks, start=1):
            ##    Task.objects.create(
             ##       habit_id=id,
              ##      task_id=idx,
              ##      day=((idx - 1) // 3) + 1,
              ##      description=task.get('task'),
              ##      is_completed=task.get('isCompleted', False)
              ##  )

            return JsonResponse({'status': 'success'}, status=201)
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)
    return JsonResponse({'error': 'Invalid request method'}, status=405)


###########################################################################################################
                                    ## save tasks ##


class HabitsWithTodayTasks(APIView):
    @permission_classes([IsAuthenticated])
    def get(self, request):
        habits = Habit.objects.filter(user=request.user)  # Filter by current user
        serializer = HabitSerializer(habits, many=True)
        return Response(serializer.data)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def update_task_status(request, task_id):
    try:
        task = Task.objects.get(id=task_id)
        task.isCompleted = request.data.get('isCompleted', task.isCompleted)
        task.save()
        return Response({'success': True})
    except Task.DoesNotExist:
        return Response({'error': 'Task not found'}, status=404)
    

################ to show reports #################################################

##from django.db.models import Count, Q


from django.utils import timezone


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def task_completion_stats(request):
    time_range = request.GET.get('range', 'daily')
    now = timezone.now()

    stats = []
    labels = []
    task_counts = []

    if time_range == 'daily':
        for i in range(7):
            date = now - timedelta(days=6 - i)
            tasks = Task.objects.filter(date=date.date())
            completed = tasks.filter(isCompleted=True).count()
            total = tasks.count()

            stats.append((completed / total) * 100 if total > 0 else 0)
            task_counts.append(completed)
            labels.append(date.strftime('%a'))

    elif time_range == 'monthly':
        for i in range(12):
            month = now.month - i
            year = now.year
            if month < 1:
                month += 12
                year -= 1

            tasks = Task.objects.filter(date__year=year, date__month=month)
            completed = tasks.filter(isCompleted=True).count()
            total = tasks.count()

            stats.append((completed / total) * 100 if total > 0 else 0)
            task_counts.append(completed)
            labels.append(datetime(year, month, 1).strftime('%b'))

        # Reverse because months were counted backwards
        stats.reverse()
        task_counts.reverse()
        labels.reverse()

    elif time_range == 'yearly':
        for i in range(5):
            year = now.year - 4 + i
            tasks = Task.objects.filter(date__year=year)
            completed = tasks.filter(isCompleted=True).count()
            total = tasks.count()

            stats.append((completed / total) * 100 if total > 0 else 0)
            task_counts.append(completed)
            labels.append(str(year))

    return Response({
        'stats': stats,
        'labels': labels,
        'taskCounts': task_counts
    })

#################################################################################
###########################################################################################








#################################################################################
###########################################################################################

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def add_coins(request):
    amount = request.data.get('amount', 0)
    if amount <= 0:
        return Response({'error': 'Invalid amount'}, status=400)
    
    # Get or create Reward record for the user
    reward, created = Reward.objects.get_or_create(user=request.user)
    reward.coins += amount
    reward.save()
    
    return Response({'new_balance': reward.coins})



@api_view(['POST'])
@permission_classes([IsAuthenticated])
def deduct_coins(request):
    amount = request.data.get('amount', 0)
    reason = request.data.get('reason', 'purchase')
    
    # Get or create Reward record for the user
    reward, created = Reward.objects.get_or_create(user=request.user)
    
    if reward.coins < amount:
        return Response({'error': 'Insufficient coins'}, status=400)
    
    reward.coins -= amount
    reward.save()

    
    return Response({'new_balance': reward.coins})


from rewards.models import Reward  # Import the Reward model

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_coin_balance(request):
    reward, created = Reward.objects.get_or_create(user=request.user)
    return Response({'balance': reward.coins})  # Changed coins.balance to reward.coins