// lib/api_services/api_constants.dart
class ApiConstants {
  static const String baseUrl = 'https://192.168.8.100:8000/';
  
  // Habit endpoints
  static const String getHabits = '$baseUrl/habits/';
  static const String updateTaskStatus = '$baseUrl/update-task/';
  
  // Challenge endpoints
  static const String getChallenges = '$baseUrl/challenges/';
  static const String getUserChallenges = '$baseUrl/user-challenges/';
  static const String joinChallenge = '$baseUrl/join-challenge/';
  
  // Add this new endpoint
  static const String updateHabit = '$baseUrl/update-habit/';
  
  // Authentication endpoints
  static const String login = '$baseUrl/login/';
  static const String register = '$baseUrl/register/';
}